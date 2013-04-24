module Synapse
  module EventStore
    # Implementation of an event store that stores events in memory; for testing purposes and
    # not thread safe
    class InMemoryEventStore < EventStore
      def initialize
        @streams = Hash.new
      end

      # Clears all streams from this event store
      def clear
        @streams.clear
      end

      # @raise [StreamNotFoundError] If the stream for the given aggregate identifier is empty
      # @param [String] aggregate_type Type descriptor of the aggregate to retrieve
      # @param [Object] aggregate_id
      # @return [DomainEventStream]
      def read_events(aggregate_type, aggregate_id)
        events = events_for aggregate_id

        if events.empty?
          raise StreamNotFoundError, 'Stream not found for [%s] [%s]' % [aggregate_type, aggregate_id]
        end

        Domain::SimpleDomainEventStream.new events
      end

      # Appends any events in the given stream to the end of the aggregate's stream
      #
      # @param [String] aggregate_type Type descriptor of the aggregate to append to
      # @param [DomainEventStream] stream
      # @return [undefined]
      def append_events(aggregate_type, stream)
        if stream.end?
          return
        end

        events = events_for stream.peek.aggregate_id

        until stream.end?
          events << stream.next_event
        end
      end

      # Clears the event stream for the given snapshot's aggregate and appends the snapshot to
      # the stream
      #
      # @param [String] aggregate_type Type descriptor of the aggregate to append to
      # @param [DomainEventMessage] snapshot_event
      # @return [undefined]
      def append_snapshot_event(aggregate_type, snapshot_event)
        events = events_for snapshot_event.aggregate_id
        events.clear
        events << snapshot_event
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
    end
  end
end
