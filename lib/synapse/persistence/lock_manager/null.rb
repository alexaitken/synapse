module Synapse
  module Persistence
    # Implementation of a lock manager that does no locking
    class NullLockManager < LockManager
      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        true
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id)
        # This method is intentionally empty
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id)
        # This method is intentionally empty
      end
    end # NullLockManager
  end # Persistence
end
