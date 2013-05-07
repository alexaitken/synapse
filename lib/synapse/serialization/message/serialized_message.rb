module Synapse
  module Serialization
    # Serialized representation of a message
    class SerializedMessage
      include SerializationAware

      # @return [String]
      attr_reader :id

      # @return [LazyObject]
      attr_reader :serialized_metadata

      # @return [LazyObject]
      attr_reader :serialized_payload

      # @param [String] id
      # @param [LazyObject] metadata
      # @param [LazyObject] payload
      # @return [undefined]
      def initialize(id, metadata, payload)
        @id = id
        @serialized_metadata = metadata
        @serialized_payload = payload
      end

      # @return [Hash] The deserialized metadata for this message
      def metadata
        @serialized_metadata.deserialized
      end

      # @return [Object] The deserialized payload for this message
      def payload
        @serialized_payload.deserialized
      end

      # @return [Class] The type of payload for this message
      def payload_type
        @serialized_payload.type
      end

      # Returns a copy of this message with the given metadata merged in
      #
      # @param [Hash] metadata
      # @return [SerializedMessage]
      def and_metadata(metadata)
        if metadata.empty?
          return self
        end

        builder = self.class.builder.new
        build_duplicate(builder, @serialized_metadat.deserialized.merge(metadata))
        builder.build
      end

      # Returns a copy of this message with the metadata replaced with the given metadata
      #
      # @param [Hash] metadata
      # @return [SerializedMessage]
      def with_metadata(metadata)
        if @serialized_metadata.deserialized == metadata
          return self
        end

        builder = self.class.builder.new
        build_duplicate(builder, metadata)
        builder.build
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_metadata(serializer, expected_type)
        serialize @serialized_metadata, serializer, expected_type
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_payload(serializer, expected_type)
        serialize @serialized_payload, serializer, expected_type
      end

      # Returns the type of builder that can be used to build this type of message
      # @return [Class]
      def self.builder
        SerializedMessageBuilder
      end

      # Yields a message builder that can be used to produce a message
      #
      # @see SerializedMessageBuilder#build
      # @yield [SerializedMessageBuilder]
      # @return [SerializedMessage]
      def self.build(&block)
        builder.build(&block)
      end

    protected

      # Populates a duplicated message with attributes from this message
      #
      # @param [SerializedMessageBuilder] message
      # @param [Hash] metadata
      # @return [undefined]
      def build_duplicate(builder, metadata)
        builder.id = @id
        builder.metadata = DeserializedObject.new metadata
        builder.payload = @serialized_payload
      end

    private

      # @param [LazyObject] object
      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize(object, serializer, expected_type)
        if object.serializer.equal? serializer
          serialized = object.serialized_object
          serializer.converter_factory.converter(serialized.content_type, expected_type).convert(serialized)
        else
          serializer.serialize(object.deserialized, expected_type)
        end
      end
    end

    # Serialized representation of an event message
    class SerializedEventMessage < SerializedMessage
      # @return [Time]
      attr_reader :timestamp

      # @param [String] id
      # @param [LazyObject] metadata
      # @param [LazyObject] payload
      # @param [Time] timestamp
      # @return [undefined]
      def initialize(id, metadata, payload, timestamp)
        super id, metadata, payload
        @timestamp = timestamp
      end

      # @return [Class]
      def self.builder
        SerializedEventMessageBuilder
      end

    protected

      # @param [SerializedEventMessageBuilder] builder
      # @param [Hash] metadata
      # @return [undefined]
      def build_duplicate(builder, metadata)
        super
        builder.timestamp = @timestamp
      end
    end

    # Serialized representation of a domain event message
    class SerializedDomainEventMessage < SerializedEventMessage
      # @return [Object]
      attr_reader :aggregate_id

      # @return [Integer]
      attr_reader :sequence_number

      # @param [String] id
      # @param [LazyObject] metadata
      # @param [LazyObject] payload
      # @param [Time] timestamp
      # @param [Object] aggregate_id
      # @param [Integer] sequence_number
      # @return [undefined]
      def initialize(id, metadata, payload, timestamp, aggregate_id, sequence_number)
        super id, metadata, payload, timestamp

        @aggregate_id = aggregate_id
        @sequence_number = sequence_number
      end

      # @return [Class]
      def self.builder
        SerializedDomainEventMessageBuilder
      end

    protected

      # @param [SerializedDomainEventMessageBuilder] builder
      # @param [Hash] metadata
      # @return [undefined]
      def build_duplicate(builder, metadata)
        super
        builder.aggregate_id = @aggregate_id
        builder.sequence_number = @sequence_number
      end
    end
  end
end