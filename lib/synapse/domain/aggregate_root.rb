module Synapse
  module Domain
    # Mixin module for a basic aggregate root that is not event-sourced
    #
    # The persistence mechanism is left up to the aggregate root that uses this mixin. Any sort of
    # ORM can be used to persist aggregates.
    #
    # If optimistic locking is used, the ORM must increment the version field before saving.
    #
    #   class Order
    #     include Synapse::Domain::AggregateRoot
    #     include MongoMapper::Document
    #
    #     key :version, Integer
    #
    #     before_save { self.version += 1 }
    #   end
    #
    # @see Repository::SimpleRepository
    module AggregateRoot
      # @return [Boolean] True if this aggregate has been marked for deletion
      attr_reader :deleted

      alias_method :deleted?, :deleted

      # @return [Object] The identifier of this aggregate
      attr_reader :id

      # @return [Integer] The version of this aggregate
      attr_reader :version

      # Marks this aggregate as committed by a repository
      #
      # @api public
      # @return [undefined]
      def mark_committed
        if @event_container
          @last_sequence_number = @event_container.last_sequence_number
          @event_container.mark_committed
        end
      end

      # Returns the number of uncommitted events published by this aggregate
      #
      # @api public
      # @return [Integer]
      def uncommitted_event_count
        unless @event_container
          return 0
        end

        @event_container.size
      end

      # Returns a domain event strema containing any uncommitted events published by this aggregate
      #
      # @api public
      # @return [DomainEventStream]
      def uncommitted_events
        unless @event_container
          return SimpleDomainEventStream.new
        end

        @event_container.to_stream
      end

      # Adds a listener that will be notified when this aggregate registers an event to be published
      #
      # If an event registration listener is added after events have already been registered, it
      # will still get a change to process the uncommitted events in this aggregate.
      #
      # @api public
      # @param [Proc] listener
      # @return [undefined]
      def add_registration_listener(&listener)
        event_container.add_registration_listener listener
      end

    protected

      # Publishes a domain event with the given payload and optional metadata
      #
      # Before any events are published, the aggregate identifier must be set.
      #
      # @api public
      # @raise [AggregateIdentifierNotInitializedError] If identifier not set
      # @param [Object] payload Payload of the message; the actual event object
      # @param [Hash] metadata Metadata associated with the event
      # @return [DomainEventMessage] The event that will be published
      def publish_event(payload, metadata = nil)
        event_container.register_event payload, metadata
      end

      # Marks this aggregate for deletion by its repository
      #
      # @api public
      # @return [undefined]
      def mark_deleted
        @deleted = true
      end

      # Returns the sequence number of the last committed event
      #
      # @api public
      # @return [Integer]
      def last_committed_sequence_number
        unless @event_container
          return @last_sequence_number
        end

        @event_container.last_committed_sequence_number
      end

    private

      # Initializes the event container with the given sequence number
      #
      # @param [Integer] last_sequence_number
      #   The sequence number of the last committed event for this aggregate
      # @return [undefined]
      def initialize_event_container(last_sequence_number)
        event_container.initialize_sequence_number last_sequence_number
        @last_sequence_number = last_sequence_number >= 0 ? last_sequence_number : nil
      end

      # Initializes the uncommitted event container for this aggregate, if not already
      #
      # @raise [AggregateIdentifierNotInitializedError] If identifier not set
      # @return [EventContainer]
      def event_container
        unless @event_container
          unless id
            raise AggregateIdentifierNotInitializedError
          end

          @event_container = EventContainer.new id
          @event_container.initialize_sequence_number @last_sequence_number
        end

        @event_container
      end
    end # AggregateRoot
  end # Domain
end
