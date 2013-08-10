module Synapse
  module Event
    # Represents a listener that can be notified of events from an event bus. Implementations are
    # highly discouraged from throwing exceptions.
    module EventListener
      include AbstractType

      # Called when an event is published to the event bus
      #
      # @param [EventMessage] event
      # @return [undefined]
      abstract_method :notify
    end # EventListener
  end # Event
end
