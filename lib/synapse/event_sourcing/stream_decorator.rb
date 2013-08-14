module Synapse
  module EventSourcing
    # Represents a mechanism for decorating event streams when aggregates are read or appended
    class EventStreamDecorator
      include AbstractType

      # Decorates an event stream when it is read from the event store
      #
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [DomainEventStream] stream
      # @return [DomainEventStream]
      abstract_method :decorate_for_read

      # Decorates an event stream when it is appended to the event store
      #
      # @param [String] type_identifier
      # @param [AggregateRoot] aggregate
      # @param [DomainEventStream] stream
      # @return [DomainEventStream]
      abstract_method :decorate_for_append
    end # EventStreamDecorator
  end # EventSourcing
end
