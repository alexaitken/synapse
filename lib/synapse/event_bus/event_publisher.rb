module Synapse
  module EventBus
    # Mixin for an object that wishes to easily be able to publish events to an event bus
    module EventPublisher
      # @return [EventBus]
      attr_accessor :event_bus

    protected

      # Publishes the given event object or event message to the configured event bus
      #
      # @param [Object] event
      # @return [undefined]
      def publish_event(event)
        @event_bus.publish(Domain::EventMessage.as_message(event))
      end
    end # EventPublisher
  end # EventBus
end
