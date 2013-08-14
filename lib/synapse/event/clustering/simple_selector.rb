module Synapse
  module Event
    # Implementation of a cluster selector that selects the same cluster for all event listeners
    class SimpleClusterSelector < ClusterSelector
      # @param [Cluster] cluster
      # @return [undefined]
      def initialize(cluster)
        @cluster = cluster
      end

      # @param [EventListener] listener
      # @return [Cluster]
      def select_for(listener)
        @cluster
      end
    end # SimpleClusterSelector
  end # Event
end
