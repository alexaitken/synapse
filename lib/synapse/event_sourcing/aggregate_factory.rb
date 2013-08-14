module Synapse
  module EventSourcing
    # Represents a mechanism for creating aggregates to be initialized by an event stream
    class AggregateFactory
      include AbstractType

      # Instantiates an aggregate using the given aggregate identifier and first event
      #
      # The first event is either the event used to create the aggregate or the most recent
      # snapshot event for the aggregate.
      #
      # @param [Object] aggregate_id
      # @param [DomainEventMessage] first_event
      # @return [AggregateRoot]
      abstract_method :create_aggregate

      # Returns the type of aggregate being created by this factory
      # @return [Class]
      abstract_method :aggregate_type

      # Returns the type identifier used to store the aggregate in the event store
      # @return [String]
      abstract_method :type_identifier
    end # AggregateFactory
  end # EventSourcing
end

