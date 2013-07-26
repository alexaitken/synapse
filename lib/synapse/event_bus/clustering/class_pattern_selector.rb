module Synapse
  module EventBus
    # Implementation of a cluster selector that matches a listener to a cluster based on
    # a regex pattern for the class name of the listener
    class ClassPatternClusterSelector < ClusterSelector
      include EventListenerProxyAware

      # @param [Cluster] cluster
      # @param [Object] pattern
      # @return [undefined]
      def initialize(cluster, pattern)
        @cluster = cluster
        @pattern = Regexp.new pattern
      end

      # @param [EventListener] listener
      # @return [Cluster]
      def select_for(listener)
        @cluster if @pattern.match(resolve_listener_type(listener).name)
      end
    end # ClassPatternClusterSelector
  end # EventBus
end
