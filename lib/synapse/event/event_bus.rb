module Synapse
  module Event
    # Represents a mechanism for event listeners to subscribe to events and for event publishers
    # to dispatch their events to any interested parties.
    #
    # Implementations may or may not dispatch the events to listeners in the dispatching thread.
    class EventBus
      include AbstractType

      # Publishes one or more events to any listeners subscribed to this event bus
      #
      # Implementations may treat the given events as a single batch and distribute them as such
      # to all subscribed event listeners.
      #
      # @param [EventMessage...] events
      # @return [undefined]
      abstract_method :publish

      # Subscribes the given listener to this event bus
      #
      # @raise [SubscriptionError] If subscription of an event listener failed
      # @param [EventListener] listener
      # @return [undefined]
      abstract_method :subscribe

      # Unsubscribes the given listener from this event bus
      #
      # @param [EventListener] listener
      # @return [undefined]
      abstract_method :unsubscribe
    end # EventBus
  end # Event
end
