module Synapse
  module EventStore
    module Mongo
      # Storage strategy that stores each event as its own document
      class DocumentPerEventStrategy < StorageStrategy
        # @param [String] type_identifier Type identifier for the aggregate
        # @param [Array] events Domain events to be committed
        # @return [Array]
        def create_documents(type_identifier, events)
          documents = Array.new

          events.each do |event|
            document = EventDocument.new
            document.from_event event, type_identifier, @serializer

            documents.push document.to_hash
          end

          documents
        end

        # @param [Hash] hash
        # @param [Object] aggregate_id
        # @return [Array]
        def extract_events(hash, aggregate_id)
          document = EventDocument.new
          document.from_hash(hash).to_events(aggregate_id, @serializer, @upcaster_chain)
        end

        # Mongo document that represents a single domain event
        class EventDocument < Serialization::SerializedDomainEventData
          # @return [String]
          attr_reader :id

          # @return [Time]
          attr_reader :timestamp

          # @return [Object]
          attr_reader :aggregate_id

          # @return [Integer]
          attr_reader :sequence_number

          # @param [SerializedObject]
          def metadata
            Serialization::SerializedMetadata.new @metadata, @metadata.class
          end

          # @param [SerializedObject]
          def payload
            Serialization::SerializedObject.new @payload, @payload.class,
              Serialization::SerializedType.new(@payload_type, @payload_revision)
          end

          # @param [DomainEventMessage] event
          # @param [String] type_identifier
          # @param [Serializer] serializer
          # @return [EventDocument]
          def from_event(event, type_identifier, serializer)
            serialization_target = String
            if serializer.can_serialize_to? Hash
              serialization_target = Hash
            end

            serialized_metadata = serializer.serialize_metadata event, serialization_target
            serialized_payload = serializer.serialize_payload event, serialization_target

            @id = event.id
            @metadata = serialized_metadata.content
            @payload = serialized_payload.content
            @payload_type = serialized_payload.type.name
            @payload_revision = serialized_payload.type.revision
            @timestamp = event.timestamp
            @aggregate_id = event.aggregate_id
            @aggregate_type = type_identifier
            @sequence_number = event.sequence_number

            self
          end

          # @param [Hash] hash
          # @return [EventDocument]
          def from_hash(hash)
            hash.symbolize_keys!

            @id = hash.fetch :_id
            @metadata = hash.fetch :metadata
            @payload = hash.fetch :payload
            @payload_type = hash.fetch :payload_type
            @payload_revision = hash.fetch :payload_revision
            @timestamp = hash.fetch :timestamp
            @aggregate_id = hash.fetch :aggregate_id
            @aggregate_type = hash.fetch :aggregate_type
            @sequence_number = hash.fetch :sequence_number

            self
          end

          # @return [Hash]
          def to_hash
            { _id: @id,
              metadata: @metadata,
              payload: @payload,
              payload_type: @payload_type,
              payload_revision: @payload_revision,
              timestamp: @timestamp,
              aggregate_id: @aggregate_id,
              aggregate_type: @aggregate_type,
              sequence_number: @sequence_number }
          end

          # @param [Object] aggregate_id
          # @param [Serializer] serializer
          # @param [UpcasterChain] upcaster_chain
          # @return [Array]
          def to_events(aggregate_id, serializer, upcaster_chain)
            events = Array.new

            context = Upcasting::SerializedDomainEventUpcastingContext.new self, aggregate_id, serializer
            upcast_objects = upcaster_chain.upcast payload, context
            upcast_objects.each do |upcast_object|
              upcast_data = Upcasting::UpcastSerializedDomainEventData.new self, aggregate_id, upcast_object

              builder = Serialization::SerializedDomainEventMessageBuilder.new

              # Prevent duplicate serialization of metadata if it was accessed during upcasting
              metadata = context.serialized_metadata
              if metadata.deserialized?
                builder.metadata = Serialization::DeserializedObject.new metadata.deserialized
              end

              builder.from_data upcast_data, serializer

              events.push builder.build
            end

            events
          end
        end # EventDocument
      end # DocumentPerEventStrategy
    end # Mongo
  end # EventStore
end # Synapse
