module Synapse
  module Event
    # Represents a logical group of event listeners that are treated as a single unit by the
    # clustering event bus. Clusters are used to apply behavior to a group of listeners, such as
    # transaction management, asynchronous publishing and distribution.
    #
    # Note that listeners should not be directly subscribed to a cluster. Use the subscription
    # mechanism provided by the clustering event bus to ensure that a cluster is properly
    # recognized by the event bus.
    class Cluster
      include AbstractType

      # Publishes the given events to any members subscribed to this cluster
      #
      # @param [EventMessage...] events
      # @return [undefined]
      abstract_method :publish

      # Subscribes an event listener to this cluster
      #
      # @param [EventListener] listener
      # @return [undefined]
      abstract_method :subscribe

      # Unsubscribes an event listener from this cluster
      #
      # @param [EventListener] listener
      # @return [undefined]
      abstract_method :unsubscribe

      # Returns the name of this cluster
      # @return [String]
      abstract_method :name

      # Returns a snapshot of the members of this cluster
      # @return [Set]
      abstract_method :members

      # Returns the metadata associated with this cluster
      # @return [ClusterMetadata]
      abstract_method :metadata
    end # Cluster
  end # Event
end
