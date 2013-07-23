module Synapse
  module EventBus
    module EventListenerProxy
      extend EventListener

      # @return [Class]
      def proxy_type
        raise NotImplementedError
      end
    end # EventListenerProxy
  end # EventBus
end
