module Synapse
  module EventSourcing
    # Mixin for an entity that is part of an event-sourced aggregate
    #
    # Instead managing its own published events, the entity relies on being registered to the
    # aggregate root and using its event container. Events applied to child entities will be
    # cascaded throughout the entire aggregate.
    module Entity
      extend ActiveSupport::Concern
      include Member

      # Handles an aggregate event locally and then cascades to any registered child entities
      #
      # @api private
      # @param [DomainEventMessage] event
      # @return [undefined]
      def handle_aggregate_event(event)
        handle_recursively event
      end

      # Registers this entity to the aggregate root
      #
      # @api private
      # @raise [RuntimeError] If entity is registered to a different aggregate root
      # @param [AggregateRoot] aggregate_root
      # @return [undefined]
      def aggregate_root=(aggregate_root)
        if @aggregate_root
          unless @aggregate_root.equal? aggregate_root
            raise 'Entity is registered to a different aggregate root'
          end
        end

        @aggregate_root = aggregate_root
      end

      protected

      # Handles the event locally and then cascades to any registered child entities
      #
      # @param [DomainEventMessage] event
      # @return [undefined]
      def handle_recursively(event)
        handle_event event

        child_entities.each do |entity|
          entity.aggregate_root = @aggregate_root
          entity.handle_aggregate_event event
        end
      end

      # Applies the given event to the aggregate and publishes it to the event container
      #
      # @param [Object] payload
      # @param [Hash] metadata
      # @return [undefined]
      def apply(payload, metadata = nil)
        unless @aggregate_root
          raise 'Entity has not been registered to an aggregate root'
        end

        @aggregate_root.handle_member_event payload, metadata
      end
    end # Entity
  end # EventSourcing
end
