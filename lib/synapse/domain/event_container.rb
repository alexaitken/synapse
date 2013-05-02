module Synapse
  module Domain
    # Container that tracks uncommitted events published by an aggregate root and its child entities
    # @api private
    class EventContainer
      # @return [Object] The identifier of the aggregate being tracked
      attr_reader :aggregate_id

      # @return [Integer] The sequence number of the last committed event
      attr_reader :last_committed_sequence_number

      # Initializes this event container
      #
      # @param [Object] aggregate_id
      #   The identifier of the aggregate being tracked
      #
      # @return [undefined]
      def initialize(aggregate_id)
        @aggregate_id = aggregate_id
        @events = Array.new
        @listeners = Array.new
      end

      # Registers an event published by the aggregate to this container
      #
      # During this process, a domain event message is created. Event registration listeners can
      # choose to modify or replace the message before it is committed.
      #
      # @param [Object] payload
      #   Payload of the message; the actual event object
      #
      # @param [Hash] metadata
      #   Metadata associated with the event
      #
      # @return [DomainEventMessage] The event that will be committed
      def register_event(payload, metadata)
        event = DomainEventMessage.build do |b|
          b.aggregate_id = @aggregate_id
          b.sequence_number = next_sequence_number
          b.metadata = metadata
          b.payload = payload
        end

        @listeners.each do |listener|
          event = listener.call event
        end

        @last_sequence_number = event.sequence_number
        @events.push event

        event
      end

      # Adds an event registration listener to this container
      #
      # If the listener is added after events have already registered with the container, it will
      # be called with a backlog of events to process.
      #
      # @param [#call] listener
      # @return [undefined]
      def add_registration_listener(listener)
        @listeners.push listener

        @events.map! do |event|
          listener.call event
        end
      end

      # Sets the last committed sequence number for the container
      #
      # @raise [RuntimeError] If events have already been registered to the container
      # @param [Integer] last_known
      # @return [undefined]
      def initialize_sequence_number(last_known)
        unless @events.empty?
          raise 'Sequence number must be set before events are registered'
        end

        @last_committed_sequence_number = last_known
      end

      # Returns the sequence number of the last event known by this container
      # @return [Integer]
      def last_sequence_number
        if @events.empty?
          return @last_committed_sequence_number
        end

        unless @last_sequence_number
          @last_sequence_number = @events.last.sequence_number
        end

        @last_sequence_number
      end

      # Updates the last committed sequence number and clears any uncommitted events and any
      # event registration listeners
      #
      # @return [undefined]
      def mark_committed
        @last_committed_sequence_number = @last_sequence_number
        @events.clear
        @listeners.clear
      end

      # Returns an event stream containing the uncommitted events in this container
      # @return [DomainEventStream]
      def to_stream
        SimpleDomainEventStream.new @events
      end

      # Returns the number of uncommitted events in this container
      # @return [Integer]
      def size
        @events.size
      end

    private

      # Returns the next sequence number to use for registered events
      # @return [Integer]
      def next_sequence_number
        last_sequence_number ? last_sequence_number.next : 0
      end
    end
  end
end
