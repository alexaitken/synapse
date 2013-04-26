module Synapse
  # Message that is monkey patched with serialization caching
  class Message
    # @api private
    alias initialize_super initialize

    # @yield [Message]
    # @return [undefined]
    def initialize(&block)
      @guard = Mutex.new
      @cache = Serialization::SerializedObjectCache.new self

      initialize_super(&block)
    end

    # @param [Serializer] serializer
    # @param [Class] expected_type
    # @return [SerializedObject]
    def serialize_metadata(serializer, expected_type)
      @guard.synchronize do
        @cache.serialize_metadata(serializer, expected_type)
      end
    end

    # @param [Serializer] serializer
    # @param [Class] expected_type
    # @return [SerializedObject]
    def serialize_payload(serializer, expected_type)
      @guard.synchronize do
        @cache.serialize_payload(serializer, expected_type)
      end
    end
  end

  module Serialization
    # This object cache is NOT thread safe and should be locked before use
    # @api private
    class SerializedObjectCache
      # @param [Message] message
      # @return [undefined]
      def initialize(message)
        @message = message
        @metadata = Hash.new
        @payload = Hash.new
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_metadata(serializer, expected_type)
        begin
          serialized = @metadata.fetch(serializer)
          serializer.converter_factory.converter(serialized.content_type, expected_type).convert(serialized)
        rescue KeyError
          serialized = serializer.serialize(@message.metadata, expected_type)
          @metadata.store(serializer, serialized)
        end
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_payload(serializer, expected_type)
        begin
          serialized = @payload.fetch(serializer)
          serializer.converter_factory.converter(serialized.content_type, expected_type).convert(serialized)
        rescue KeyError
          serialized = serializer.serialize(@message.payload, expected_type)
          @payload.store(serializer, serialized)
        end
      end
    end
  end
end
