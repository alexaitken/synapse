module Synapse
  module Event
    # Represents an event listener that directs publication to another event listener
    module EventListenerProxy
      include AbstractType
      include EventListener

      # Returns the type of the event listener being proxied
      # @return [Class]
      abstract_method :proxied_type
    end # EventListenerProxy
  end # Event
end
