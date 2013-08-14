module Synapse
  module Event
    # Represents a mechanism used to select the cluster that will manage subscription for
    # an event listener
    #
    # Implementations may choose to not select a cluster for all event listeners; in this case,
    # an event listener may not be subscribed to the event bus.
    class ClusterSelector
      include AbstractType
      # Returns the cluster that will be used to manage the subscription of the given event
      # listener
      #
      # @param [EventListener] listener
      # @return [Cluster]
      abstract_method :select_for
    end # ClusterSelector
  end # Event
end
