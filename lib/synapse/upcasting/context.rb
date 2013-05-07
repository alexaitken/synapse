module Synapse
  module Upcasting
    # Provides contextual information about an object being upcast; generally this is information
    # from the message containing the object to be upcast
    #
    # @abstract
    class UpcastingContext
      # @abstract
      # @return [String]
      def message_id; end

      # @abstract
      # @return [Hash]
      def metadata; end

      # @abstract
      # @return [Time]
      def timestamp; end

      # @abstract
      # @return [Object]
      def aggregate_id; end

      # @abstract
      # @return [Integer]
      def sequence_number; end
    end

    # Upcasting context that provides information from serialized domain event data
    class SerializedDomainEventUpcastingContext < UpcastingContext
      # @return [Object]
      attr_reader :aggregate_id

      # @return [LazyObject]
      attr_reader :serialized_metadata

      # @param [SerializedDomainEventData] event_data
      # @param [Object] aggregate_id
      # @param [Serializer] serializer
      # @return [undefined]
      def initialize(event_data, aggregate_id, serializer)
        @aggregate_id = aggregate_id
        @event_data = event_data
        @serialized_metadata = Serialization::LazyObject.new @event_data.metadata, serializer
      end

      # @return [String]
      def message_id
        @event_data.id
      end

      # @return [Hash]
      def metadata
        @serialized_metadata.deserialized
      end

      # @return [Time]
      def timestamp
        @event_data.timestamp
      end

      # @return [Integer]
      def sequence_number
        @event_data.sequence_number
      end
    end
  end
end
