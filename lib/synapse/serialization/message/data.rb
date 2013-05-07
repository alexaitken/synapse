module Synapse
  module Serialization
    # Describes the properties that a serialized domain event should have
    # @abstract
    class SerializedDomainEventData
      # @return [String] Identifier of the serialized event
      def id; end

      # @return [SerializedObject] Serialized metadata of the serialized event
      def metadata; end

      # @return [SerializedObject] Serialized payload of the serialized event
      def payload; end

      # @return [Time] Timestamp of the serialized event
      def timestamp; end

      # @return [Object] Identifier of the aggregate that the event was applied to
      def aggregate_id; end

      # @return [Integer] Sequence number of the event in the aggregate
      def sequence_number; end
    end
  end
end
