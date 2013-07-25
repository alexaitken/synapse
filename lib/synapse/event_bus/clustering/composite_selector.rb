module Synapse
  module EventBus
    # Implementation of a cluster selector that delegates selection to a list of selectors,
    # trying each one until a cluster is selected.
    class CompositeClusterSelector
      # @param [Enumerable<ClusterSelector>] selectors
      # @return [undefined]
      def initialize(selectors)
        @selectors = Array.new selectors
      end

      # @param [EventListener] listener
      # @return [Cluster]
      def select_for(listener)
        cluster = nil

        @selectors.each do |selector|
          cluster = selector.select_for listener
          break if cluster
        end

        cluster
      end
    end # CompositeClusterSelector
  end # EventBus
end
