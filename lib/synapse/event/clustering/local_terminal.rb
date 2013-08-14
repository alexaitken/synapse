module Synapse
  module Event
    # Implementation of an event bus terminal that publishes events locally
    class LocalEventBusTerminal < EventBusTerminal
      # @return [undefined]
      def initialize
        @clusters = Contender::CopyOnWriteArray.new
      end

      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        @clusters.each do |cluster|
          cluster.publish *events
        end
      end

      # @param [Cluster] cluster
      # @return [undefined]
      def on_cluster_creation(cluster)
        @clusters.push cluster
      end
    end # LocalEventBusTerminal
  end # Event
end
