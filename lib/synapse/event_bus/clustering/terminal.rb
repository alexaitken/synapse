module Synapse
  module EventBus
    # Represents a mechanism used to connect clusters on the event bus
    #
    # The terminal is responsible for delivering events, whether it is done locally
    # or remotely
    #
    # @abstract
    class EventBusTerminal
      # Publishes the given events to all clusters on the event bus
      #
      # @abstract
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        raise NotImplementedError
      end

      # Called when a cluster was selected that was previously unknown to the event bus
      #
      # @abstract
      # @param [Cluster] cluster
      # @return [undefined]
      def on_cluster_creation(cluster)
        raise NotImplementedError
      end
    end # EventBusTerminal

    # Implementation of an event bus terminal that publishes events locally
    class LocalEventBusTerminal < EventBusTerminal
      # @return [undefined]
      def initialize
        # @todo This should be a thread-safe structure
        @clusters = Array.new
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
  end # EventBus
end
