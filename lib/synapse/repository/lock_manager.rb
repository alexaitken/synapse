module Synapse
  module Repository
    # Represents a mechanism for locking aggregates for modification
    # @abstract
    class LockManager
      # Ensures that the current thread holds a valid lock for the given aggregate
      #
      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        true
      end

      # Obtains a lock for an aggregate with the given aggregate identifier. Depending on
      # the strategy, this method may return immediately or block until a lock is held.
      #
      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id); end

      # Releases the lock held for an aggregate with the given aggregate identifier. The caller
      # of this method must ensure a valid lock was requested using {#obtain_lock}. If no lock
      # was successfully obtained, the behavior of this method is undefined.
      #
      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id); end
    end
  end
end
