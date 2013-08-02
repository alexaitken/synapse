module Synapse
  module Saga
    # Represents a mechanism for synchronizing access to sagas
    # @abstract
    class LockManager
      # Obtains a lock for a saga with the given identifier, blocking if necessary
      #
      # @abstract
      # @param [String] saga_id
      # @return [undefined]
      def obtain_lock(saga_id); end

      # Releases the lock for a saga with the given identifier
      #
      # @abstract
      # @raise [ThreadError] If thread didn't previously hold the lock
      # @param [String] saga_id
      # @return [undefined]
      def release_lock(saga_id); end
    end # LockManager

    # Implementation of a lock manager that performs no locking. This is useful when a type of
    # saga is thread safe and does not need any additional synchronization.
    class NullLockManager < LockManager
      # @param [String] saga_id
      # @return [undefined]
      def obtain_lock(saga_id)
        # This method is intentionally empty
      end

      # @param [String] saga_id
      # @return [undefined]
      def release_lock(saga_id)
        # This method is intentionally empty
      end
    end # NullLockManager
  end # Saga
end
