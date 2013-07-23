module Synapse
  module EventBus
    module EventListenerProxyAware
      # @param [EventListener] listener
      # @return [Class]
      def resolve_listener_type(listener)
        if listener.respond_to? :proxy_type
          listener.proxy_type
        else
          listener.class
        end
      end

      private :resolve_listener_type
    end # EventListenerProxyAware
  end # EventBus
end
