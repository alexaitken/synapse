module Synapse
  module EventBus
    # Provides a mechanism used to resolve the actual type of an event listener for purposes
    # of logging or subscription management
    module EventListenerProxyAware
      # Returns the actual type of an event listener
      #
      # If the event listener is a proxy, the proxied type is returned. Otherwise, the
      # type of the given listener is returned.
      #
      # @param [EventListener] listener
      # @return [Class]
      def resolve_listener_type(listener)
        if listener.respond_to? :proxied_type
          listener.proxied_type
        else
          listener.class
        end
      end

      private :resolve_listener_type
    end # EventListenerProxyAware
  end # EventBus
end
