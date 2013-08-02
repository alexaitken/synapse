module Synapse
  module EventStore
    # Thread-safe implementation of an event store that stores events in memory
    # @api public
    class InMemoryEventStore < EventStore
      # @return [undefined]
      def initialize
        @mutex = Mutex.new
        @streams = Hash.new do |hash, key|
          hash.put key, Array.new
        end
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
        @mutex.synchronize do
          unless @streams.key? aggregate_id
            raise StreamNotFoundError.new type_identifier, aggregate_id
          end

          stream = @streams.fetch aggregate_id

          Domain::SimpleDomainEventStream.new stream
        end
      end

      # @api public
      # @param [String] type_identifier Type descriptor of the aggregate to append to
      # @param [DomainEventStream] stream
      # @return [undefined]
      def append_events(type_identifier, stream)
        return if stream.end?

        aggregate_id = stream.peek.aggregate_id

        @mutex.synchronize do
          events = @streams.get aggregate_id

          until stream.end?
            events.push stream.next_event
          end
        end
      end

      # Retrieves an array containing the event stream for the given aggregate identifier
      #
      # @api public
      # @param [Object] aggregate_id
      # @return [Array]
      def events_for(aggregate_id)
        @mutex.synchronize do
          @streams.get aggregate_id
        end
      end
    end # InMemoryEventStore
  end # EventStore
end
