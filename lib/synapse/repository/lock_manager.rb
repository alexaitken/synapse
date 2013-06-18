module Synapse
  module Repository
    # Represents a mechanism for locking aggregates for modification
    # @abstract
    class LockManager
      # Ensures that the current thread holds a valid lock for the given aggregate
      #
      # @abstract
      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        raise NotImplementedError
      end

      # Obtains a lock for an aggregate with the given aggregate identifier. Depending on
      # the strategy, this method may return immediately or block until a lock is held.
      #
      # @abstract
      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id)
        raise NotImplementedError
      end

      # Releases the lock held for an aggregate with the given aggregate identifier. The caller
      # of this method must ensure a valid lock was requested using {#obtain_lock}. If no lock
      # was successfully obtained, the behavior of this method is undefined.
      #
      # @abstract
      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id)
        raise NotImplementedError
      end
    end # LockManager

    # Implementation of a lock manager that does no locking
    class NullLockManager < LockManager
      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        true
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id); end

      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id); end
    end # NullLockManager
  end # Repository
end
