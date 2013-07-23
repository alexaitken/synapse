module Synapse
  module EventBus
    class CompositeClusterSelector
      # @return [undefined]
      def initialize
        @selectors = Array.new
      end

      # @param [ClusterSelector] selector
      # @return [CompositeClusterSelector] For fluent interface
      def push(selector)
        @selectors.push selector
        self
      end

      alias_method :<<, :push

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
