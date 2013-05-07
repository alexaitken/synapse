module Synapse
  module Upcasting
    class UpcastSerializedDomainEventData < Serialization::SerializedDomainEventData
      # @param [SerializedDomainEventData] original
      # @param [Object] aggregate_id
      # @param [SerializedObject] upcast_payload
      # @return [undefined]
      def initialize(original, aggregate_id, upcast_payload)
        @original = original
        @aggregate_id = aggregate_id
        @upcast_payload = upcast_payload
      end

      # @return [String]
      def id
        @original.id
      end

      # @return [SerializedObject]
      def metadata
        @original.metadata
      end

      # @return [SerializedObject]
      def payload
        @upcast_payload
      end

      # @return [Time]
      def timestamp
        @original.timestamp
      end

      # @return [Object]
      def aggregate_id
        @aggregate_id
      end

      # @return [Integer]
      def sequence_number
        @original.sequence_number
      end
    end
  end
end
