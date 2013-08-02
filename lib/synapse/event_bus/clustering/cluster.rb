module Synapse
  module EventBus
    # Represents a logical group of event listeners that are treated as a single unit by the
    # clustering event bus. Clusters are used to apply behavior to a group of listeners, such as
    # transaction management, asynchronous publishing and distribution.
    #
    # Note that listeners should not be directly subscribed to a cluster. Use the subscription
    # mechanism provided by the clustering event bus to ensure that a cluster is properly
    # recognized by the event bus.
    #
    # @abstract
    class Cluster
      # Publishes the given events to any members subscribed to this cluster
      #
      # @abstract
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        raise NotImplementedError
      end

      # Subscribes an event listener to this cluster
      #
      # @abstract
      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        raise NotImplementedError
      end

      # Unsubscribes an event listener from this cluster
      #
      # @abstract
      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        raise NotImplementedError
      end

      # Returns the name of this cluster
      # @abstract
      # @return [String]
      def name
        raise NotImplementedError
      end

      # Returns a snapshot of the members of this cluster
      #
      # @abstract
      # @return [Set]
      def members
        raise NotImplementedError
      end

      # Returns the metadata associated with this cluster
      #
      # @abstract
      # @return [ClusterMetadata]
      def metadata
        raise NotImplementedError
      end
    end # Cluster
  end # EventBus
end
