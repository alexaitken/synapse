module Synapse
  module EventStore
    # Implementation of an event store that stores events in memory; for testing purposes and
    # not thread safe
    #
    # @todo This should be a thread-safe structure
    class InMemoryEventStore < EventStore
      def initialize
        @streams = Hash.new
      end

      # Clears all streams from this event store
      def clear
        @streams.clear
      end

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

      # Appends any events in the given stream to the end of the aggregate's stream
      #
      # @param [String] type_identifier Type descriptor of the aggregate to append to
      # @param [DomainEventStream] stream
      # @return [undefined]
      def append_events(type_identifier, stream)
        if stream.end?
          return
        end

        events = events_for stream.peek.aggregate_id

        until stream.end?
          events.push stream.next_event
        end
      end

      # Creates and/or retrieves an array of events for the given aggregate identifier
      #
      # @param [Object] aggregate_id
      # @return [Array<DomainEventMessage>]
      def events_for(aggregate_id)
        if @streams.has_key? aggregate_id
          return @streams.fetch aggregate_id
        end

        @streams.store aggregate_id, Array.new
      end
    end # InMemoryEventStore
  end # EventStore
end
