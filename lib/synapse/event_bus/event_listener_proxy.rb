module Synapse
  module EventBus
    # @abstract
    module EventListenerProxy
      # @abstract
      # @return [Class]
      def target_type; end
    end
  end
end
