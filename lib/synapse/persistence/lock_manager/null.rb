module Synapse
  module Persistence
    # Implementation of a lock manager that does no locking
    class NullLockManager < LockManager
      # @return [Boolean]
      def validate_lock(*)
        true
      end

      # @return [undefined]
      def obtain_lock(*)
        # This method is intentionally empty
      end

      # @return [undefined]
      def release_lock(*)
        # This method is intentionally empty
      end
    end # NullLockManager
  end # Persistence
end
