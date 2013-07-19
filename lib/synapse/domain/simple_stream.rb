module Synapse
  module Domain
    # Implementation of a domain event stream that holds a stream of events in memory
    class SimpleDomainEventStream < DomainEventStream
      # @param [EventMessage...] events
      # @return [undefined]
      def initialize(*events)
        @events = events.flatten
        @next_index = 0
      end

      # @api public
      # @return [Boolean]
      def end?
        @next_index >= @events.size
      end

      # @api public
      # @raise [EndOfStreamError] If the end of the stream has been reached
      # @return [DomainEventMessage]
      def next_event
        assert_valid

        event = @events.at @next_index
        @next_index += 1

        event
      end

      # @api public
      # @raise [EndOfStreamError] If the end of the stream has been reached
      # @return [DomainEventMessage]
      def peek
        assert_valid
        @events.at @next_index
      end
    end # SimpleDomainEventStream
  end # Domain
end
