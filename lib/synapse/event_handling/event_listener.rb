module Synapse
  module EventHandling
    # Represents a listener that can be notified of events from an event bus. Implementations are
    # highly discouraged from throwing exceptions.
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
