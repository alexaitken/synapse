module Synapse
  module EventBus
    # @abstract
    module EventListenerProxy
      extend EventListener

      # @abstract
      # @return [Class]
      def target_type; end
    end
  end
end
