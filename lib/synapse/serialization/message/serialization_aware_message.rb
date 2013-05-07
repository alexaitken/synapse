module Synapse
  module Serialization
    # Decorator for an event message that adds serialization awareness
    #
    # Any serialization that occurs on the metadata or payload of this message will be
    # cached so that if a message is serialized more than once, the serialization process will
    # only occur once.
    class SerializationAwareEventMessage
      extend Forwardable
      include SerializationAware

      # @param [EventMessage] message
      # @return [SerializationAwareEventMessage]
      def self.decorate(message)
        if message.is_a? SerializationAware
          return message
        end

        self.new message
      end

      # @param [EventMessage] message
      # @return [undefined]
      def initialize(message)
        @message = message
        @cache = SerializedObjectCache.new message
      end

      # @param [Hash] metadata
      # @return [SerializationAwareEventMessage]
      def and_metadata(metadata)
        new_message = @message.and_metadata metadata
        if new_message.equal? @message
          return self
        end

        self.class.new new_message
      end

      # @param [Hash] metadata
      # @return [SerializationAwareEventMessage]
      def with_metadata(metadata)
        new_message = @message.with_metadata metadata
        if new_message.equal? @message
          return self
        end

        self.class.new new_message
      end

      # Delegators for the serialized object cache
      def_delegators :@cache, :serialize_metadata, :serialize_payload

      # Delegators for message attribute readers
      def_delegators :@message, :id, :metadata, :payload, :payload_type, :timestamp
    end

    # Decorator for a domain event message that adds serialization awareness
    class SerializationAwareDomainEventMessage < SerializationAwareEventMessage
      # Delegators for domain event specific attribute readers
      def_delegators :@message, :aggregate_id, :sequence_number
    end
  end
end
