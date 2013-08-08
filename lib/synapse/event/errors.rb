module Synapse
  module Event
    # Raised when the subscription of an event listener has not succeeded. Generally, this means that
    # some precondition set by an event bus implementation for the listener have not been met.
    class SubscriptionError < NonTransientError; end
  end
end
