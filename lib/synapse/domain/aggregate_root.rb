module Synapse
  module Domain
    # Mixin module for a basic aggregate root
    module AggregateRoot
      # @return [Boolean] True if this aggregate has been marked for deletion
      attr_reader :deleted

      alias deleted? deleted

      # @return [Object] The identifier of this aggregate
      attr_reader :id

      # @return [Integer] The version of this aggregate
      attr_reader :version

      # Adds a listener that will be notified when this aggregate registers an event to be published
      #
      # If an event registration listener is added after events have already been registered, it
      # will still get a change to process the uncommitted events in this aggregate.
      #
      # @param [#call] listener
      # @return [undefined]
      def add_registration_listener(&listener)
        event_container.add_registration_listener listener
      end

      # Marks this aggregate as committed by a repository
      # @return [undefined]
      def mark_committed
        if @event_container
          @last_sequence_number = @event_container.last_sequence_number
          @event_container.mark_committed
        end
      end

      # Returns the number of uncommitted events published by this aggregate
      # @return [Integer]
      def uncommitted_event_count
        unless @event_container
          return 0
        end

        @event_container.size
      end

      # Returns a domain event strema containing any uncommitted events published by this aggregate
      # @return [DomainEventStream]
      def uncommitted_events
        unless @event_container
          return SimpleDomainEventStream.new
        end

        @event_container.to_stream
      end

    protected

      # Publishes a domaine vent with the given payload and metadata (optional)
      #
      # @param [Object] payload
      #   Payload of the message; the actual event object
      #
      # @param [Hash] metadata
      #   Metadata associated with the event
      #
      # @return [DomainEventMessage] The event that will be committed
      def publish_event(payload, metadata = nil)
        event_container.register_event payload, metadata
      end

      # Initializes the event container with the given sequence number
      #
      # @param [Integer] last_sequence_number
      #   The sequence number of the last committed event for this aggregate
      #
      # @return [undefined]
      def initialize_event_container(last_sequence_number)
        event_container.initialize_sequence_number last_sequence_number
        @last_sequence_number = last_sequence_number >= 0 ? last_sequence_number : nil
      end

      # Returns the sequence number of the last committed event
      # @return [Integer]
      def last_committed_sequence_number
        unless @event_container
          return @last_sequence_number
        end

        @event_container.last_committed_sequence_number
      end

      # Marks this aggregate for deletion by its repository
      # @return [undefined]
      def mark_deleted
        @deleted = true
      end

    private

      # Initializes the uncommitted event container for this aggregate, if not already
      #
      # @raise [AggregateIdentifierNotInitializedError] If identifier not set
      # @return [EventContainer]
      def event_container
        unless @event_container
          unless @id
            raise AggregateIdentifierNotInitializedError
          end

          @event_container = EventContainer.new @id
          @event_container.initialize_sequence_number @last_sequence_number
        end

        @event_container
      end
    end

    # Raised when an event is published but the aggregate identifier is not set
    class AggregateIdentifierNotInitializedError < NonTransientError; end
  end
end
