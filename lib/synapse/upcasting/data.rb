module Synapse
  module Upcasting
    class UpcastSerializedDomainEventData < Serialization::SerializedDomainEventData
      extend Forwardable

      # @param [SerializedDomainEventData] original
      # @param [Object] aggregate_id
      # @param [SerializedObject] upcast_payload
      # @return [undefined]
      def initialize(original, aggregate_id, upcast_payload)
        @original = original
        @aggregate_id = aggregate_id
        @upcast_payload = upcast_payload
      end

      # @return [SerializedObject]
      def payload
        @upcast_payload
      end

      # @return [Object]
      def aggregate_id
        @aggregate_id
      end

      # Delegators for serialized domain event data
      def_delegators :@original, :id, :metadata, :timestamp, :sequence_number
    end
  end
end
