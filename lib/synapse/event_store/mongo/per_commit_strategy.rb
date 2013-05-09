module Synapse
  module EventStore
    module Mongo
      # Storage strategy that stores all events in a commit operation in a single document
      #
      # Since Mongo doesn't support transactions, this can be used as a substitute to guarantee
      # atomic storage of events. The only downside is that it may be harder to query events
      # from the event store.
      #
      # Performance also seems to be better using this strategy
      class DocumentPerCommitStrategy < StorageStrategy
        # @param [String] type_identifier Type identifier for the aggregate
        # @param [Array] events Domain events to be committed
        # @return [Array]
        def create_documents(type_identifier, events)
          document = CommitDocument.new
          document.from_events(type_identifier, events, @serializer).to_hash
        end

        # @param [Hash] hash
        # @param [Object] aggregate_id
        # @return [Array]
        def extract_events(hash, aggregate_id)
          document = CommitDocument.new
          document.from_hash(hash).to_events(aggregate_id, @serializer, @upcaster_chain)
        end

        # Mongo document that represents a commit containing one or more events
        class CommitDocument
          # @return [Object]
          attr_reader :aggregate_id

          # @param [String] type_identifier
          # @param [Array] events
          # @param [Serializer] serializer
          # @return [CommitDocument]
          def from_events(type_identifier, events, serializer)
            first_event = events.first
            last_event = events.last

            @aggregate_type = type_identifier
            @aggregate_id = first_event.aggregate_id.to_s
            @first_sequence_number = first_event.sequence_number
            @last_sequence_number = last_event.sequence_number
            @first_timestamp = first_event.timestamp
            @last_timestamp = last_event.timestamp

            @events = Array.new
            events.each do |event|
              event_document = EventDocument.new
              event_document.from_event event, serializer

              @events.push event_document
            end

            self
          end

          # @param [Hash] hash
          # @return [CommitDocument]
          def from_hash(hash)
            hash.symbolize_keys!

            @aggregate_id = hash.fetch :aggregate_id
            @aggregate_type = hash.fetch :aggregate_type
            @first_sequence_number = hash.fetch :first_sequence_number
            @last_sequence_number = hash.fetch :last_sequence_number
            @first_timestamp = hash.fetch :first_timestamp
            @last_timestamp = hash.fetch :last_timestamp

            @events = Array.new

            event_hashes = hash.fetch :events
            event_hashes.each do |event_hash|
              event_document = EventDocument.new
              event_document.from_hash event_hash

              @events.push event_document
            end

            self
          end

          # @return [Hash]
          def to_hash
            events = Array.new
            @events.each do |event|
              events.push event.to_hash
            end

            { aggregate_id: @aggregate_id,
              aggregate_type: @aggregate_type,
              # Allows us to use the same query to filter events as DocumentPerEvent
              sequence_number: @first_sequence_number,
              first_sequence_number: @first_sequence_number,
              last_sequence_number: @last_sequence_number,
              # Allows us to use the same query to filter events as DocumentPerEvent
              timestamp: @first_timestamp,
              first_timestamp: @first_timestamp,
              last_timestamp: @last_timestamp,
              events: events }
          end

          # @param [Object] aggregate_id The actual aggregate identifier used to query the evnet store
          # @param [Serializer] serializer
          # @param [UpcasterChain] upcaster_chain
          # @return [Array]
          def to_events(aggregate_id, serializer, upcaster_chain)
            events = Array.new

            @events.each do |event_document|
              event_data = DocumentDomainEventData.new aggregate_id, event_document
              context = Upcasting::SerializedDomainEventUpcastingContext.new event_data, aggregate_id, serializer

              upcast_objects = upcaster_chain.upcast event_document.payload, context
              upcast_objects.each do |upcast_object|
                upcast_data = Upcasting::UpcastSerializedDomainEventData.new event_data, aggregate_id, upcast_object

                builder = Serialization::SerializedDomainEventMessageBuilder.new

                # Prevent duplicate serialization of metadata if it was accessed during upcasting
                metadata = context.serialized_metadata
                if metadata.deserialized?
                  builder.metadata = Serialization::DeserializedObject.new metadata.deserialized
                end

                builder.from_data upcast_data, serializer

                events.push builder.build
              end
            end

            events
          end
        end # CommitDocument

        # Mongo document that represents a single event as part of a commit document
        class EventDocument
          # @return [String]
          attr_reader :id

          # @return [Time]
          attr_reader :timestamp

          # @return [Integer]
          attr_reader :sequence_number

          # @return [SerializedObject]
          def metadata
            Serialization::SerializedMetadata.new @metadata, @metadata.class
          end

          # @return [SerializedObject]
          def payload
            Serialization::SerializedObject.new @payload, @payload.class,
              Serialization::SerializedType.new(@payload_type, @payload_revision)
          end

          # @param [EventMessage] event
          # @param [Serializer] serializer
          # @return [EventDocument]
          def from_event(event, serializer)
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
            @sequence_number = event.sequence_number

            self
          end

          # @param [Hash] hash
          # @return [EventDocument]
          def from_hash(hash)
            hash.symbolize_keys!

            @id = hash.fetch :id
            @metadata = hash.fetch :metadata
            @payload = hash.fetch :payload
            @payload_type = hash.fetch :payload_type
            @payload_revision = hash.fetch :payload_revision
            @timestamp = hash.fetch :timestamp
            @sequence_number = hash.fetch :sequence_number

            self
          end

          # @return [Hash]
          def to_hash
            { id: @id,
              metadata: @metadata,
              payload: @payload,
              payload_type: @payload_type,
              payload_revision: @payload_revision,
              timestamp: @timestamp,
              sequence_number: @sequence_number }
          end
        end # EventDocument

        # Serialized domain event data from an event document
        class DocumentDomainEventData < Serialization::SerializedDomainEventData
          # @param [Object] aggregate_id
          # @param [EventDocument] event_document
          # @return [undefined]
          def initialize(aggregate_id, event_document)
            @aggregate_id = aggregate_id
            @event_document = event_document
          end

          # @return [String]
          def id
            @event_document.id
          end

          # @return [SerializedObject]
          def metadata
            @event_document.metadata
          end

          # @return [SerializedObject]
          def payload
            @event_document.payload
          end

          # @return [Time]
          def timestamp
            @event_document.timestamp
          end

          # @return [Object]
          def aggregate_id
            @aggregate_id
          end

          # @return [Integer]
          def sequence_number
            @event_document.sequence_number
          end
        end # DocumentDomainEventData
      end # DocumentPerCommitStrategy
    end # Mongo
  end # EventStore
end # Synapse
