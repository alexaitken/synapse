module Synapse
  module Repository
    # Implementation of a lock manager that blocks until a lock can be obtained
    class PessimisticLockManager < LockManager
      # @return [undefined]
      def initialize
        @manager = IdentifierLockManager.new
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        @manager.owned? aggregate.id
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id)
        @manager.obtain_lock aggregate_id
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id)
        @manager.release_lock aggregate_id
      end
    end # PessimisticLockManager
  end # Repository
end
