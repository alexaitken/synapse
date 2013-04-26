module Synapse
  module Domain
    # Represents a historical stream of domain events in chronological order
    #
    # @example
    #   stream = InMemoryDomainEventStream.new events
    #   until stream.end?
    #     puts stream.next_event
    #   end
    #
    # @example
    #   stream = InMemoryDomainEventStream.new events
    #   stream.each do |event|
    #     puts event
    #   end
    #
    # @abstract
    class DomainEventStream
      # Returns true if the end of the stream has been reached
      #
      # @abstract
      # @return [Boolean]
      def end?
        true
      end

      # Returns the next event in the stream and moves the stream's pointer forward
      #
      # @abstract
      # @return [DomainEventMessage]
      def next_event; end

      # Returns the next event in the stream without moving the stream's pointer forward
      #
      # @abstract
      # @return [DomainEventMessage]
      def peek; end

      # Yields the next domain events in the stream until the end of the stream has been reached
      #
      # @yield [DomainEventMessage] The next event in the event stream
      # @return [undefined]
      def each
        until end?
          yield next_event
        end
      end

      # Returns the domain events in this stream as an array
      # @return [Array<DomainEventMessage>]
      def to_a
        events = Array.new
        each do |event|
          events << event
        end

        events
      end

    protected

      def assert_valid
        if end?
          raise EndOfStreamError
        end
      end
    end

    # Raised when the end of a domain event stream has been reached
    class EndOfStreamError < NonTransientError; end

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
    end
  end
end
