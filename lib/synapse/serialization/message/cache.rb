module Synapse
  # Message that is monkey patched with serialization caching
  class Message
    # @api private
    alias initialize_super initialize

    # @yield [Message]
    # @return [undefined]
    def initialize(*args)
      @cache_lock = Mutex.new
      initialize_super(*args)
    end

    # @param [Serializer] serializer
    # @param [Class] expected_type
    # @return [SerializedObject]
    def serialize_metadata(serializer, expected_type)
      with_cache do |cache|
        cache.serialize_metadata(serializer, expected_type)
      end
    end

    # @param [Serializer] serializer
    # @param [Class] expected_type
    # @return [SerializedObject]
    def serialize_payload(serializer, expected_type)
      with_cache do |cache|
        cache.serialize_payload(serializer, expected_type)
      end
    end

  private

    # @yield [SerializedObjectCache]
    # @return [undefined]
    def with_cache
      @cache_lock.synchronize do
        @cache ||= Serialization::SerializedObjectCache.new self
        yield @cache
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
        serialize @message.metadata, @metadata, serializer, expected_type
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_payload(serializer, expected_type)
        serialize @message.payload, @payload, serializer, expected_type
      end

    private

      # @param [Object] original
      # @param [Hash] cache
      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize(original, cache, serializer, expected_type)
        begin
          serialized = cache.fetch(serializer)
          serializer.converter_factory.converter(serialized.content_type, expected_type).convert(serialized)
        rescue KeyError
          serialized = serializer.serialize(original, expected_type)
          cache.store(serializer, serialized)
        end
      end
    end
  end
end
