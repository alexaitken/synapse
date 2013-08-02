module Synapse
  module EventStore
    # Implementation of an event store that stores events in memory
    # @api public
    class InMemoryEventStore < EventStore
      # @return [undefined]
      def initialize
        @streams = ThreadSafe::Cache.new
      end

      # Clears all streams from this event store
      #
      # @api public
      # @return [undefined]
      def clear
        @streams.clear
      end

      # @api public
      # @raise [StreamNotFoundError] If the stream for the given aggregate identifier is empty
      # @param [String] type_identifier Type descriptor of the aggregate to retrieve
      # @param [Object] aggregate_id
      # @return [DomainEventStream]
      def read_events(type_identifier, aggregate_id)
        events = events_for aggregate_id

        if events.empty?
          raise StreamNotFoundError.new type_identifier, aggregate_id
        end

        Domain::SimpleDomainEventStream.new events
      end

      # @api public
      # @param [String] type_identifier Type descriptor of the aggregate to append to
      # @param [DomainEventStream] stream
      # @return [undefined]
      def append_events(type_identifier, stream)
        return if stream.end?

        events = events_for stream.peek.aggregate_id

        until stream.end?
          events.push stream.next_event
        end
      end

      # Retrieves an array containing the event stream for the given aggregate identifier
      #
      # @api public
      # @param [Object] aggregate_id
      # @return [Array]
      def events_for(aggregate_id)
        @streams.compute_if_absent aggregate_id do
          Array.new
        end
      end
    end # InMemoryEventStore
  end # EventStore
end
