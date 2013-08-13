module Synapse
  module Serialization
    # Thread-safe cache for messages to store serialized metadata and payload
    # @api private
    class SerializedObjectCache
      # @param [Message] message
      # @return [undefined]
      def initialize(message)
        @message = message

        @metadata_cache = Hash.new
        @metadata_mutex = Mutex.new
        @payload_cache = Hash.new
        @payload_mutex = Mutex.new
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_metadata(serializer, expected_type)
        @metadata_mutex.synchronize do
          serialize @message.metadata, @metadata_cache, serializer, expected_type
        end
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_payload(serializer, expected_type)
        @payload_mutex.synchronize do
          serialize @message.payload, @payload_cache, serializer, expected_type
        end
      end

      private

      # Calls to this method must be synchronized
      #
      # @param [Object] object
      # @param [Hash] cache
      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize(object, cache, serializer, expected_type)
        serialized = cache.get serializer

        if serialized
          serializer.converter_factory.convert serialized, expected_type
        else
          serialized = serializer.serialize object, expected_type
          cache.put serializer, serialized
          serialized
        end
      end
    end # SerializedObjectCache
  end # Serialization
end

