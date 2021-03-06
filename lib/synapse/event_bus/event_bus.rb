module Synapse
  module EventBus
    # Represents a mechanism for event listeners to subscribe to events and for event publishers
    # to dispatch their events to any interested parties.
    #
    # Implementations may or may not dispatch the events to listeners in the dispatching thread.
    #
    # @abstract
    class EventBus
      # Publishes one or more events to any listeners subscribed to this event bus
      #
      # Implementations may treat the given events as a single batch and distribute them as such
      # to all subscribed event listeners.
      #
      # @abstract
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        raise NotImplementedError
      end

      # Subscribes the given listener to this event bus
      #
      # @abstract
      # @raise [SubscriptionError] If subscription of an event listener failed
      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        raise NotImplementedError
      end

      # Unsubscribes the given listener from this event bus
      #
      # @abstract
      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        raise NotImplementedError
      end
    end

    # Raised when the subscription of an event listener has not succeeded. Generally, this means that
    # some precondition set by an event bus implementation for the listener have not been met.
    class SubscriptionError < NonTransientError; end
  end
end
