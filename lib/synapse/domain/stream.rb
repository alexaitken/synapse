module Synapse
  module Domain
    # Represents a historical stream of domain events in chronological order
    #
    # @example
    #   stream = SimpleDomainEventStream.new events
    #   until stream.end?
    #     puts stream.next_event
    #   end
    #
    # @example
    #   stream = SimpleDomainEventStream.new events
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
        raise NotImplementedError
      end

      # Returns the next event in the stream and moves the stream's pointer forward
      #
      # @abstract
      # @return [DomainEventMessage]
      def next_event
        raise NotImplementedError
      end

      # Returns the next event in the stream without moving the stream's pointer forward
      #
      # @abstract
      # @return [DomainEventMessage]
      def peek
        raise NotImplementedError
      end

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
      # @return [Array]
      def to_a
        events = Array.new
        each do |event|
          events.push event
        end

        events
      end

      protected

      # @raise [EndOfStreamError] If at the end of the stream
      # @return [undefined]
      def assert_valid
        raise EndOfStreamError if end?
      end
    end # DomainEventStream
  end # Domain
end
