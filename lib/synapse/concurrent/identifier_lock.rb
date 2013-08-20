module Synapse
  module Concurrent
    class IdentifierLock
      @mutex = Mutex.new
      @instances = Ref::WeakKeyMap.new

      # @param [IdentifierLock] instance
      # @return [undefined]
      def self.add(instance)
        @mutex.synchronize do
          @instances.put instance, true
        end
      end

      # @return [Array]
      def self.instances
        @mutex.synchronize do
          @instances.keys
        end
      end

      # @param [Thread] thread
      # @param [Array] managers
      # @return [Set]
      def self.waiters_for_locks_owned_by(thread, managers = nil)
        managers ||= instances
        waiters = Set.new

        managers.each do |manager|
          manager.internal_locks.each do |disposable_lock|
            next unless disposable_lock.owned_by? thread

            disposable_lock.queued_threads.each do |waiter|
              if waiters.add? waiter
                waiters = waiters.union(waiters_for_locks_owned_by(waiter, managers))
              end
            end
          end
        end

        waiters
      end

      # @return [IdentifierLock]
      def self.new
        super.tap { |il| add il }
      end

      # @return [undefined]
      def initialize
        @locks = ThreadSafe::Cache.new
      end

      # @param [Object] identifier
      # @return [Boolean]
      def owned?(identifier)
        lock_available?(identifier) && lock_for(identifier).owned?
      end

      # @raise [LockAcquisitionError]
      # @param [Object] identifier
      # @return [undefined]
      def obtain_lock(identifier)
        obtained = false
        until obtained
          lock = lock_for identifier
          obtained = lock.lock
          unless obtained
            @locks.delete_pair identifier, lock
          end
        end
      end

      # @raise [LockUsageError]
      # @param [Object] identifier
      # @return [undefined]
      def release_lock(identifier)
        unless lock_available? identifier
          raise LockUsageError, 'Calling thread does not own lock with the given identifier'
        end

        lock = lock_for identifier
        lock.unlock

        try_dispose identifier, lock
      end

      # @api private
      # @return [Array]
      def internal_locks
        @locks.values
      end

      private

      # @param [Object] identifier
      # @return [Boolean]
      def lock_available?(identifier)
        @locks.key? identifier
      end

      # @param [Object] identifier
      # @return [DisposableLock]
      def lock_for(identifier)
        lock = @locks.get identifier
        until lock
          @locks.put_if_absent identifier, DisposableLock.new
          lock = @locks.get identifier
        end

        lock
      end

      # @param [Object] identifier
      # @param [DisposableLock] lock
      # @return [undefined]
      def try_dispose(identifier, lock)
        if lock.try_close
          @locks.delete_pair identifier, lock
        end
      end
    end # IdentifierLock

    class DisposableLock
      extend Forwardable

      # @return [undefined]
      def initialize
        @lock = ReentrantLock.new
        @closed = false
      end

      # @return [Boolean]
      def closed?
        @closed
      end

      def_delegators :@lock, :owned?, :owned_by?, :queued_threads

      # @raise [LockAcquisitionError]
      # @return [Boolean] True if lock was acquired
      def lock
        begin
          unless @lock.try_timed_lock(0)
            loop do
              check_for_deadlock

              # TODO Jitter is added here because in tests, the two threads would execute at pretty
              # much the same time and would never figure out why they are deadlocking
              #
              # Although nearly the same algorithm is used for locking as the original impl in
              # Java, I would venture to say that Ruby and Java thread scheduling work differently,
              # possibly even in JRuby. (Either that or my ReentrantLock impl is broken)
              break if @lock.try_timed_lock(TimeUnit.milliseconds(100 * rand))
            end
          end
        rescue Interrupt
          raise LockAcquisitionError, 'Thread interrupted during lock acquisition'
        end

        if @closed
          @lock.unlock
          return false
        end

        true
      end

      # @return [undefined]
      def unlock
        @lock.unlock
      end

      # @return [Boolean]
      def try_close
        if @lock.try_lock
          begin
            if @lock.hold_count == 1
              @closed = true
              return true
            end
          ensure
            @lock.unlock
          end
        end

        false
      end

      private

      # @raise [DeadlockError]
      # @return [undefined]
      def check_for_deadlock
        return if @lock.owned?
        return unless @lock.locked?

        waiters = IdentifierLock.waiters_for_locks_owned_by Thread.current
        waiters.each do |waiter|
          if @lock.owned_by? waiter
            raise DeadlockError, 'Imminent deadlock detected during lock acquisition'
          end
        end
      end
    end # DisposableLock
  end # Concurrent
end
