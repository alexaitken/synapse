module Synapse
  module Repository
    # Rough implementation of a pessimistic lock manager using local locks
    class PessimisticLockManager < LockManager
      def initialize
        @aggregates = IdentifierLock.new
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        @aggregates.owned? aggregate.id
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id)
        @aggregates.obtain_lock aggregate_id
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id)
        @aggregates.release_lock aggregate_id
      end
    end
  end
end
