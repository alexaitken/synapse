module Synapse
  module Saga
    # Implementation of a lock manager that performs no locking. This is useful when a type of
    # saga is thread safe and does not need any additional synchronization.
    class NullLockManager < LockManager
      # @return [undefined]
      def obtain_lock(*)
        # This method is intentionally empty
      end

      # @return [undefined]
      def release_lock(*)
        # This method is intentionally empty
      end
    end # NullLockManager
  end # Saga
end
