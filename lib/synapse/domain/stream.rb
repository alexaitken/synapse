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
      include AbstractType

      # Returns true if the end of the stream has been reached
      # @return [Boolean]
      abstract_method :end?

      # Returns the next event in the stream and moves the stream's pointer forward
      # @return [DomainEventMessage]
      abstract_method :next_event

      # Returns the next event in the stream without moving the stream's pointer forward
      # @return [DomainEventMessage]
      abstract_method :peek

      # Yields the next domain events in the stream until the end of the stream has been reached
      #
      # @yield [DomainEventMessage] The next event in the event stream
      # @return [undefined]
      def each
        yield next_event until end?
      end

      # Returns the domain events in this stream as an array
      # @return [Array]
      def to_a
        events = []
        each do |event|
          events.push event
        end

        events
      end

      protected

      # @raise [EndOfStreamError] If at the end of the stream
      # @return [undefined]
      def ensure_valid
        raise EndOfStreamError if end?
      end
    end # DomainEventStream
  end # Domain
end
