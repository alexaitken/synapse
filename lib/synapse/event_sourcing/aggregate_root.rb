module Synapse
  module EventSourcing
    # Mixin for the root entity of an aggregate that is initialized from a historical event stream
    module AggregateRoot
      extend ActiveSupport::Concern
      include Domain::AggregateRoot
      include Member

      module ClassMethods
        # Creates a new instance of this aggregate root without calling its initializer and
        # initializes the state of the aggregate from the given event stream.
        #
        # @param [DomainEventStream] stream
        # @return [AggregateRoot]
        def new_from_stream(stream)
          aggregate = allocate
          aggregate.initialize_from_stream stream
          aggregate
        end
      end

      # @return [Integer] The sequence number of the last committed event
      def version
        last_committed_sequence_number
      end

      # Initializes the state of this aggregate from the given domain event stream
      #
      # @raise [RuntimeError] If aggregate has already been initialized
      # @param [DomainEventStream] stream
      # @return [undefined]
      def initialize_from_stream(stream)
        if uncommitted_event_count > 0
          raise 'Aggregate has already been initialized'
        end

        pre_initialize

        last_sequence_number = nil

        stream.each do |event|
          last_sequence_number = event.sequence_number
          handle_recursively event
        end

        initialize_event_container last_sequence_number
      end

      # Called when a member of the aggregate publishes an event
      #
      # This is only meant to be invoked by entities that are members of this aggregate
      #
      # @api private
      # @param [Object] payload
      # @param [Hash] metadata
      # @return [undefined]
      def handle_member_event(payload, metadata = nil)
        apply payload, metadata
      end

    protected

      # Hook that is called before the aggregate is initialized
      # @return [undefined]
      def pre_initialize; end

      # Creates an event with the given metadata and payload, publishes it using the event
      # container, and finally handles it locally and recursively down the aggregate.
      #
      # @api public
      # @param [Object] payload
      # @param [Hash] metadata
      # @return [undefined]
      def apply(payload, metadata = nil)
        if id
          event = publish_event payload, metadata
          handle_recursively event
        else
          # This is a workaround for aggregates that set the aggregate identifier in an event handler
          event = Domain::DomainEventMessage.build do |builder|
            builder.metadata = metadata
            builder.payload = payload
            builder.sequence_number = 0
          end

          handle_recursively event
          publish_event payload, metadata
        end
      end

      # Handles the event locally and then cascades to any registered child entities
      #
      # @api private
      # @param [DomainEventMessage] event
      # @return [undefined]
      def handle_recursively(event)
        handle_event event

        child_entities.each do |entity|
          entity.aggregate_root = self
          entity.handle_aggregate_event event
        end
      end
    end
  end
end
