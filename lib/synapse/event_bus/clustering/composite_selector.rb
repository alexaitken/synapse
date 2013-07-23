module Synapse
  module EventBus
    class CompositeClusterSelector
      # @param [Array] selectors
      # @return [undefined]
      def initialize(selectors)
        @selectors = selectors
      end

      # @param [EventListener] listener
      # @return [Cluster]
      def select_for(listener)
        @selectors.find do |selector|
          selector.select_for listener
        end
      end
    end # CompositeClusterSelector
  end # EventBus
end
