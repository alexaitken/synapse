module Synapse
  module EventBus
    # Represents a listener that can be notified of events from an event bus. Implementations are
    # highly discouraged from throwing exceptions.
    #
    # @see MappingEventListener
    # @abstract
    module EventListener
      # Called when an event is published to the event bus
      #
      # @abstract
      # @param [EventMessage] event
      # @return [undefined]
      def notify(event)
        raise NotImplementedError
      end
    end # EventListener
  end # EventBus
end
