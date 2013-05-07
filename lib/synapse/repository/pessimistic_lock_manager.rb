module Synapse
  module Repository
    # Rough implementation of a pessimistic lock manager using local locks
    class PessimisticLockManager < LockManager
      def initialize
        @aggregates = Hash.new
        @lock = Mutex.new
      end

      # @todo Check if current thread holds lock, not just if lock is held
      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        @aggregates.has_key?(aggregate.id) and lock_for(aggregate.id).locked?
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id)
        lock = lock_for aggregate_id
        lock.lock
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id)
        unless @aggregates.has_key? aggregate_id
          raise 'No lock for this identifier was ever obtained'
        end

        lock = lock_for aggregate_id
        lock.unlock
      end

    private

      # @param [Object] aggregate_id
      # @return [Mutex]
      def lock_for(aggregate_id)
        lock = @aggregates[aggregate_id]
        until lock
          put_if_absent aggregate_id, Mutex.new
          lock = @aggregates[aggregate_id]
        end
        lock
      end

      # @param [Object] aggregate_id
      # @param [Mutex] lock
      # @return [undefined]
      def put_if_absent(aggregate_id, lock)
        @lock.synchronize do
          unless @aggregates.has_key? aggregate_id
            @aggregates.store aggregate_id, lock
          end
        end
      end

    end
  end
end
