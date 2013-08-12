module Synapse
  module Persistence
    # Implementation of a lock manager that blocks until a lock can be acquired
    class PessimisticLockManager < LockManager
      # @return [undefined]
      def initialize
        @lock = Concurrent::IdentifierLock.new
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        @lock.owned? aggregate.id
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id)
        @lock.obtain_lock aggregate_id
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id)
        @lock.release_lock aggregate_id
      end
    end # PessimisticLockManager
  end # Persistence
end
