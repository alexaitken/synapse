module Synapse
  module Repository
    # Lock manager that uses an optimistic locking strategy
    #
    # This implementation uses the sequence number of an aggregate's last committed event to
    # detect concurrenct access.
    class OptimisticLockManager < LockManager
      # @return [undefined]
      def initialize
        @aggregates = Hash.new
        @mutex = Mutex.new
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate_lock(aggregate)
        @aggregates.has_key?(aggregate.id) && @aggregates[aggregate.id].validate(aggregate)
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def obtain_lock(aggregate_id)
        obtained = false
        until obtained
          lock = lock_for aggregate_id
          obtained = lock && lock.lock
          unless obtained
            remove_lock aggregate_id, lock
          end
        end
      end

      # @param [Object] aggregate_id
      # @return [undefined]
      def release_lock(aggregate_id)
        lock = @aggregates[aggregate_id]
        if lock
          lock.unlock
          if lock.closed?
            remove_lock aggregate_id, lock
          end
        end
      end

    private

      # @param [Object] aggregate_id
      # @param [OptimisticLock] lock
      # @return [undefined]
      def remove_lock(aggregate_id, lock)
        @mutex.synchronize do
          if @aggregates.has_key?(aggregate_id) && @aggregates[aggregate_id] === lock
            @aggregates.delete aggregate_id
          end
        end
      end

      # @param [Object] aggregate_id
      # @return [OptimisticLock]
      def lock_for(aggregate_id)
        @mutex.synchronize do
          if @aggregates.has_key? aggregate_id
            @aggregates[aggregate_id]
          else
            @aggregates[aggregate_id] = OptimisticLock.new
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
        @threads = Hash.new 0
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def validate(aggregate)
        last_committed = aggregate.version
        if @version.nil? || @version == last_committed
          @version = (last_committed || 0) + aggregate.uncommitted_event_count
          true
        else
          false
        end
      end

      # @return [Boolean] Returns false if lock is closed
      def lock
        if @closed
          false
        else
          @threads[Thread.current] = @threads[Thread.current] + 1
          true
        end
      end

      # @return [undefined]
      def unlock
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
    end # OptimisticLock
  end # Repository
end
