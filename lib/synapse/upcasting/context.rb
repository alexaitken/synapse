module Synapse
  module Upcasting
    # Provides contextual information about an object being upcast; generally this is information
    # from the message containing the object to be upcast
    #
    # @abstract
    class UpcastingContext
      # @abstract
      # @return [String]
      def message_id
        raise NotImplementedError
      end

      # @abstract
      # @return [Hash]
      def metadata
        raise NotImplementedError
      end

      # @abstract
      # @return [Time]
      def timestamp
        raise NotImplementedError
      end

      # @abstract
      # @return [Object]
      def aggregate_id
        raise NotImplementedError
      end

      # @abstract
      # @return [Integer]
      def sequence_number
        raise NotImplementedError
      end
    end

    # Upcasting context that provides information from serialized domain event data
    class SerializedDomainEventUpcastingContext < UpcastingContext
      extend Forwardable

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

      # @return [Hash]
      def metadata
        @serialized_metadata.deserialized
      end

      # Delegators for serialized domain event data
      def_delegators :@event_data, :id, :timestamp, :sequence_number
    end
  end
end
