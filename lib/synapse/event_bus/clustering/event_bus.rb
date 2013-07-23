module Synapse
  module EventBus
    class ClusteringEventBus < EventBus
      include EventListenerProxyAware
      include Loggable

      # @param [ClusterSelector] cluster_selector
      # @param [EventBusTerminal] terminal
      # @return [undefined]
      def initialize(cluster_selector, terminal)
        # @todo This should be a thread-safe structure
        @clusters = Set.new
        @cluster_selector = cluster_selector
        @terminal = terminal
      end

      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        @terminal.publish *events
      end

      # @raise [SubscriptionError] If subscription of an event listener failed
      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        raise NotImplementedError
      end

      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        raise NotImplementedError
      end

      private

      def cluster_for(listener)
        listener_type = resolve_listener_type listener
        cluster = @cluster_selector.select_for listener

        unless cluster
          raise SubscriptionError, "No cluster was selected for listener {#{listener_type}}"
        end

        logger.debug "Cluster {#{cluster.class}} {#{cluster.name}} was selected for listener {#{listener_type}}"

        if @clusters.add? cluster
          logger.debug "Cluster {#{cluster.class}} {#{cluster.name}} is now known to the terminal"
          @terminal.on_cluster_creation cluster
        end

        cluster
      end
    end # ClusteringEventBus
  end # EventBus
end
