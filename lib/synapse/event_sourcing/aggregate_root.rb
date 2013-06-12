module Synapse
  module EventSourcing
    # Mixin for the root entity of an aggregate that is initialized from a historical event stream
    #
    # = Handling events
    #
    # For ease of use, the event mapping DSL is included in event-sourced aggregates. This includes
    # both the aggregate root and any entities that are a member of the aggregate.
    #
    # This mapping DSL can be used to map handlers for events that have been applied to the
    # aggregate
    #
    #   class Order
    #     include Synapse::EventSourcing::AggregateRoot
    #
    #     def add_item(sku, quantity, unit_price)
    #       # Do business logic validation here
    #       apply(new ItemsAddedToOrder(id, sku, quantity, unit_price))
    #     end
    #
    #     map_event ItemsAddedToOrder do |event|
    #       @value = @value + (event.quantity * event.unit_price)
    #       @line_items.add(OrderLineItem.new(sku, quantity, unit_price))
    #     end
    #   end
    #
    # Events applied to the aggregate root are cascaded down to any child entities of the aggregate
    # root. Events applied to a child entity are actually applied to the aggregate root's event
    # container, and are then cascaded down to the child entities.
    #
    # = Initialization
    #
    # An aggregate can be initialized in three ways:
    #
    # - Created by the caller using new, usually to create a new aggregate
    # - Allocated, then initialized from an event stream
    # - Deserialized from a snapshot
    #
    # Because of the different ways the aggregate can be created, it is necessary to separate out
    # the logic needed to create data structures required by the aggregate to function.
    #
    # Ruby does not support method overloading, so there is a hook provided to do any logic
    # necessary to instantiate the aggregate, such as creating collections.
    #
    #   class Order
    #     include Synapse::EventSourcing::AggregateRoot
    #
    #     def initialize(id, max_value)
    #       pre_initialize
    #       apply(OrderCreated.new(id, max_value))
    #     end
    #
    #   protected
    #
    #     def pre_initialize
    #       @line_items = Set.new
    #     end
    #   end
    #
    # Instead of using the pre-initialization hook, you can also do lazy initialization.
    #
    #   class Order
    #     include Synapse::EventSourcing::AggregateRoot
    #
    #     def line_items
    #       @line_items ||= Set.new
    #     end
    #   end
    #
    # = Snapshots
    #
    # When the event stream for an aggregate becomes large, it can put a drain on the application
    # to have to load the entire stream of an aggregate just to perform a single operation upon
    # it.
    #
    # To solve this issue, Synapse supports snapshotting aggregates. The built-in way to snapshot
    # is simply to serialize the aggregate root, since it contains entire state of the aggregate.
    #
    # When using a marshalling serializer, like the built-in Ruby marshaller or ones like Oj and
    # Ox, no work needs to be done to prepare the aggregate for serialization. However, when using
    # the attribute serializer, you have to treat snapshots as mementos.
    #
    #   class Order
    #     include Synapse::EventSourcing::AggregateRoot
    #
    #     def attributes
    #       line_items = @line_items.map { |li| li.attributes }
    #       { id: @id, value: @value }
    #     end
    #
    #     # Note that this is called after #allocate
    #     def attributes=(attributes)
    #       @id = attributes[:id]
    #       @value = attributes[:value]
    #       # Yeah, it's pretty ugly to support this
    #       @line_items = attributes[:line_items].map do |line_item|
    #         OrderLineItem.allocate.tap { |li| li.attributes = line_item }
    #       end
    #     end
    #   end
    #
    # It would be nice to have something like XStream to make serialization easier, but as far as
    # I can tell, there's nothing even close to it for Ruby.
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

      # The sequence number of the first event that the aggregate was initialized from
      #
      # If the aggregate was initialized from a snapshot, this should be reset to the sequence
      # number of the last event in the snapshot. Otherwise, this will be the sequence number
      # of the first event contained in the event stream used to initialize the aggregate.
      #
      # @return [Integer]
      attr_reader :initial_version

      # @return [Integer] The sequence number of the last committed event
      def version
        last_committed_sequence_number
      end

      # Resets the initial version to the current version of the aggregate
      # @return [undefined]
      def reset_initial_version
        @initial_version = last_committed_sequence_number
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

        # If this is loaded from a snapshot, don't pre-initialize
        pre_initialize unless @initial_version

        @initial_version = stream.peek.sequence_number

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
    end # AggregateRoot
  end # EventSourcing
end
