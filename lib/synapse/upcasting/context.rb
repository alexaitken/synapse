module Synapse
  module Upcasting
    # Provides contextual information about an object being upcast; generally this is information
    # from the message containing the object to be upcast
    class UpcastingContext
      # @param [SerializedDomainEventData] serialized_data
      # @param [Serializer] serializer
      # @return [undefined]
      def initialize(serialized_data, serializer)
        @serialized_data = serialized_data
        @metadata = Serialization::LazyObject.new @serialized_data.metadata, serializer
      end

      # @return [String]
      def message_id
        @serialized_data.id
      end

      # @return [Hash]
      def metadata
        @metadata.deserialized
      end

      # @return [Time]
      def timestamp
        @serialized_data.timestamp
      end

      # @return [Object]
      def aggregate_id
        @serialized_data.aggregate_id
      end

      # @return [Integer]
      def sequence_number
        @serialized_data.sequence_number
      end
    end
  end
end
