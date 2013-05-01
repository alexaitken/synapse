module Synapse
  module EventSourcing
    # Represents a mechanism for decorating event streams when aggregates are read or appended
    # @abstract
    class EventStreamDecorator
      # Decorates an event stream when it is read from the event store
      #
      # @abstract
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [DomainEventStream] stream
      # @return [DomainEventStream]
      def decorate_for_read(type_identifier, aggregate_id, stream); end

      # Decorates an event stream when it is appended to the event store
      #
      # @abstract
      # @param [String] type_identifier
      # @param [AggregateRoot] aggregate
      # @param [DomainEventStream] stream
      # @return [DomainEventStream]
      def decorate_for_append(type_identifier, aggregate, stream); end
    end
  end
end
