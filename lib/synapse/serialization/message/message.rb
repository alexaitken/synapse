module Synapse
  module Serialization
    # Implementation of a message that can be lazily deserialized
    class SerializedMessage
      # @return [String] Unique identifier of this message
      attr_accessor :id

      # @return [LazyObject]
      attr_accessor :serialized_metadata

      # @return [LazyObject]
      attr_accessor :serialized_payload

      # @yield [SerializedMessage]
      # @return [undefined]
      def initialize
        yield self if block_given?

        freeze
      end

      # @return [Hash]
      def metadata
        @serialized_metadata.deserialized
      end

      # @return [Object]
      def payload
        @serialized_payload.deserialized
      end

      # @return [Class]
      def payload_type
        @serialized_payload.type
      end

      # Convenience method used to populate the lazy object attributes
      #
      # @param [SerializedObject] metadata
      # @param [SerializedObject] payload
      # @param [Serializer] serializer
      # @return [undefined]
      def with_serialized(metadata, payload, serializer)
        @serialized_metadata = LazyObject.new metadata, serializer
        @serialized_payload = LazyObject.new payload, serializer
      end

      # Returns a copy of this message with the given metadata merged in
      #
      # @param [Hash] metadata
      # @return [SerializedMessage]
      def and_metadata(metadata)
        self.class.new do |message|
          merged_metadata = @serialized_metadata.deserialized.merge metadata
          populate_duplicate message, merged_metadata
        end
      end

      # Returns a copy of this message with the metadata replaced with the given metadata
      #
      # @param [Hash] metadata
      # @return [SerializedMessage]
      def with_metadata(metadata)
        self.class.new do |message|
          populate_duplicate message, metadata
        end
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

    protected

      # Populates a duplicated message with attributes from this method
      #
      # @param [SerializedMessage] message
      # @param [Hash] metadata
      # @return [undefined]
      def populate_duplicate(message, metadata)
        message.id = @id
        message.serialized_metadata = DeserializedObject.new metadata
        message.serialized_payload = @serialized_payload
      end

    private

      # @param [LazyObject] object
      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize(object, serializer, expected_type)
        if serializer == object.serializer
          serialized = object.serialized_object
          serializer.converter_factory.converter(serialized.content_type, expected_type).convert(serialized)
        else
          serializer.serialize object.deserialized, expected_type
        end
      end
    end
  end
end
