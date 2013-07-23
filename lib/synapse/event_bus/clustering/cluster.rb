module Synapse
  module EventBus
    # Represents a logical group of event listeners that are treated as a single unit by the
    # clustering event bus. Clusters are used to apply behavior to a group of listeners, such as
    # transaction management, asynchronous publishing and distribution.
    #
    # @abstract
    class Cluster
      # @abstract
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        raise NotImplementedError
      end

      # @abstract
      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        raise NotImplementedError
      end

      # @abstract
      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        raise NotImplementedError
      end

      # @abstract
      # @return [String]
      def name
        raise NotImplementedError
      end

      # @abstract
      # @return [Set]
      def members
        raise NotImplementedError
      end

      # @abstract
      # @return [Hash]
      def metadata
        raise NotImplementedError
      end
    end # Cluster
  end # EventBus
end
