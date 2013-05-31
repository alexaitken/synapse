module Synapse
  module Serialization
    # Thread-safe cache for messages to store serialized metadata and payload
    # @api private
    class SerializedObjectCache
      # @param [Message] message
      # @return [undefined]
      def initialize(message)
        @message = message
        @lock = Mutex.new
        @metadata_cache = Hash.new
        @payload_cache = Hash.new
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_metadata(serializer, expected_type)
        serialize @message.metadata, @metadata_cache, serializer, expected_type
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_payload(serializer, expected_type)
        serialize @message.payload, @payload_cache, serializer, expected_type
      end

    private

      # @param [Object] object
      # @param [Hash<Serializer, SerializedObject>] cache
      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize(object, cache, serializer, expected_type)
        @lock.synchronize do
          serialized = cache[serializer]
          if serialized
            serializer.converter_factory.convert serialized, expected_type
          else
            serialized = serializer.serialize object, expected_type
            cache[serializer] = serialized
            serialized
          end
        end
      end
    end # SerializedObjectCache
  end # Serialization
end
