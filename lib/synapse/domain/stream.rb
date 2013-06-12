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
          events.push event
        end

        events
      end

    protected

      def assert_valid
        if end?
          raise EndOfStreamError
        end
      end
    end # DomainEventStream
  end # Domain
end
