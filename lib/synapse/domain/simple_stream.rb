module Synapse
  module Domain
    # Implementation of a domain event stream that holds a stream of events in memory
    class SimpleDomainEventStream < DomainEventStream
      def initialize(*events)
        @events = events.flatten
        @next_index = 0
      end

      # Returns true if the end of the stream has been reached
      # @return [Boolean]
      def end?
        @next_index >= @events.size
      end

      # Returns the next event in the stream and moves the stream's pointer forward
      #
      # @raise [EndOfStreamError] If the end of the stream has been reached
      # @return [DomainEventMessage]
      def next_event
        assert_valid

        event = @events.at @next_index
        @next_index += 1

        event
      end

      # Returns the next event in the stream without moving the stream's pointer forward
      #
      # @raise [EndOfStreamError] If the end of the stream has been reached
      # @return [DomainEventMessage]
      def peek
        assert_valid
        @events.at @next_index
      end
    end # SimpleDomainEventStream
  end # Domain
end
