module Synapse
  module EventBus
    # Represents an event listener that directs publication to another event listener
    # @abstract
    module EventListenerProxy
      extend EventListener

      # Returns the type of the event listener being proxied
      #
      # @abstract
      # @return [Class]
      def proxied_type
        raise NotImplementedError
      end
    end # EventListenerProxy
  end # EventBus
end
