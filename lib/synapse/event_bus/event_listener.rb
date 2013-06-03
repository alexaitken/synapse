module Synapse
  module EventBus
    # Represents a listener that can be notified of events from an event bus. Implementations are
    # highly discouraged from throwing exceptions.
    #
    # Consider using the event listener mixin that uses the mapping DSL.
    #
    # @abstract
    module EventListener
      # Called when an event is published to the event bus
      #
      # @abstract
      # @param [EventMessage] event
      # @return [undefined]
      def notify(event); end
    end
  end
end
