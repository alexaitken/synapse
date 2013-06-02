module Synapse
  module EventSourcing
    # Represents a mechanism for creating aggregates to be initialized by an event stream
    # @abstract
    class AggregateFactory
      # Instantiates an aggregate using the given aggregate identifier and first event
      #
      # The first event is either the event used to create the aggregate or the most recent
      # snapshot event for the aggregate.
      #
      # @abstract
      # @param [Object] aggregate_id
      # @param [DomainEventMessage] first_event
      # @return [AggregateRoot]
      def create_aggregate(aggregate_id, first_event); end

      # @abstract
      # @return [Class] Type of aggregate being created by this factory
      def aggregate_type; end

      # @abstract
      # @return [String] Type identifier used to store the aggregate in the event store
      def type_identifier; end
    end # AggregateFactory

    # Aggregate factory that uses a convention to create instances of aggregates
    class GenericAggregateFactory < AggregateFactory
      # @return [Class]
      attr_reader :aggregate_type

      # @return [String]
      attr_reader :type_identifier

      # @param [Class] aggregate_type
      # @return [undefined]
      def initialize(aggregate_type)
        @aggregate_type = aggregate_type
        @type_identifier = aggregate_type.to_s.demodulize
      end

      # @param [Object] aggregate_id
      # @param [DomainEventMessage] first_event
      # @return [AggregateRoot]
      def create_aggregate(aggregate_id, first_event)
        payload = first_event.payload

        if payload.is_a? AggregateRoot
          aggregate = payload
          aggregate.reset_initial_version
        else
          aggregate = @aggregate_type.allocate
        end

        post_process aggregate
      end

    protected

      # Performs any processing that must be done on an aggregate instance that was reconstructed
      # from a snapshot event. Implementations may choose to modify the existing instance or return
      # a new instance.
      #
      # @param [AggregateRoot] aggregate
      # @return [AggregateRoot]
      def post_process(aggregate)
        aggregate
      end
    end # GenericAggregateFactory
  end # EventSourcing
end
