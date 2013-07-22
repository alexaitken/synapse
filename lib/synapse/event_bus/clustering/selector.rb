module Synapse
  module EventBus
    # Represents a mechanism used to select the cluster that will manage subscription for
    # an event listener
    #
    # Implementations may choose to not select a cluster for all event listeners; in this case,
    # an event listener may not be subscribed to the event bus.
    #
    # @abstract
    class ClusterSelector
      # Returns the cluster that will be used to manage the subscription of the given event
      # listener
      #
      # @abstract
      # @param [EventListener] listener
      # @return [Cluster]
      def select_for(listener)
        raise NotImplementedError
      end
    end # ClusterSelector
  end # EventBus
end
