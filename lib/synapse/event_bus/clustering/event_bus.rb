module Synapse
  module EventBus
    class ClusteringEventBus < EventBus
      include EventListenerProxyAware
      include Loggable

      # @param [ClusterSelector] cluster_selector
      # @param [EventBusTerminal] terminal
      # @return [undefined]
      def initialize(cluster_selector, terminal)
        @cluster_selector = cluster_selector
        @terminal = terminal

        @clusters = Contender::CopyOnWriteSet.new
      end

      # @api public
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        @terminal.publish *events.flatten
      end

      # @api public
      # @raise [SubscriptionError] If subscription of an event listener failed
      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        cluster_for(listener).subscribe(listener)
      end

      # @api public
      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        cluster_for(listener).unsubscribe(listener)
      end

      private

      # @raise [SubscriptionError] If no cluster could be selected
      # @param [EventListener] listener
      # @return [Cluster]
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
