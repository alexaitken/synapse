module Synapse
  module Serialization
    # Describes the properties that a serialized domain event should have
    # @abstract
    class SerializedDomainEventData
      # @abstract
      # @return [String] Identifier of the serialized event
      def id
        raise NotImplementedError
      end

      # @abstract
      # @return [SerializedObject] Serialized metadata of the serialized event
      def metadata
        raise NotImplementedError
      end

      # @abstract
      # @return [SerializedObject] Serialized payload of the serialized event
      def payload
        raise NotImplementedError
      end

      # @abstract
      # @return [Time] Timestamp of the serialized event
      def timestamp
        raise NotImplementedError
      end

      # @abstract
      # @return [Object] Identifier of the aggregate that the event was applied to
      def aggregate_id
        raise NotImplementedError
      end

      # @abstract
      # @return [Integer] Sequence number of the event in the aggregate
      def sequence_number
        raise NotImplementedError
      end
    end # SerializedDomainEventData
  end # Serialization
end
