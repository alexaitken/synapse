module Synapse
  module Repository
    # Lock manager that uses an optimistic locking strategy
    #
    # This implementation uses the sequence number of an aggregate's last committed event to
    # detect concurrenct access.
    class OptimisticLockManager < LockManager
      # @return [undefined]
      def initialize
        @locks = ThreadSafe::Cache.new
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        lock = @locks.get aggregate.id
        lock && lock.validate(aggregate)
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id)
        obtained = false
        until obtained
          @locks.put_if_absent aggregate_id, OptimisticLock.new
          lock = @locks.get aggregate_id
          obtained = lock && lock.lock

          unless obtained
            @locks.delete_pair aggregate_id, lock
          end
        end
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id)
        lock = @locks.get aggregate_id
        if lock
          lock.unlock
          if lock.closed?
            @locks.delete_pair aggregate_id, lock
          end
        end
      end
    end # OptimisticLockManager

    # Lock that keeps track of an aggregate's version
    # @api private
    class OptimisticLock
      # @return [Boolean] True if this lock can be disposed
      attr_reader :closed

      alias_method :closed?, :closed

      # @return [Hash] Hash of threads to the number of times they hold the lock
      attr_reader :threads

      def initialize
        @closed = false
        @threads = Ref::WeakKeyMap.new
        @mutex = Mutex.new
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate(aggregate)
        synchronize do
          last_committed = aggregate.version
          if @version.nil? || @version == last_committed
            last = last_committed || 0
            @version = last + aggregate.uncommitted_event_count
            true
          else
            false
          end
        end
      end

      # @return [Boolean] Returns false if lock is closed
      def lock
        synchronize do
          if @closed
            false
          else
            lock_count = @threads[Thread.current] || 0
            @threads[Thread.current] = lock_count + 1
            true
          end
        end
      end

      # @return [undefined]
      def unlock
        synchronize do
          count = @threads[Thread.current]
          if count <= 1
            @threads.delete Thread.current
          else
            @threads[Thread.current] = @threads[Thread.current] - 1
          end

          if @threads.empty?
            @closed = true
          end
        end
      end

      private

      # @yield
      # @return [Object]
      def synchronize
        @mutex.synchronize do
          yield
        end
      end
    end # OptimisticLock
  end # Repository
end
