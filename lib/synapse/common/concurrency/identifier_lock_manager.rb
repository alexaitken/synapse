module Synapse
  # Generic lock manager that can be used to lock identifiers for exclusive access
  class IdentifierLockManager
    @mutex = Mutex.new
    @instances = Ref::WeakKeyMap.new

    class << self
      # @api private
      # @return [Array]
      def instances
        @mutex.synchronize do
          @instances.keys
        end
      end

      # @api private
      # @param [IdentifierLockManager] instance
      # @return [undefined]
      def add(instance)
        @mutex.synchronize do
          @instances[instance] = true
        end
      end

      # @api private
      # @param [Thread] thread
      # @return [Set]
      def waiters_for_locks_owned_by(thread)
        stack = Array.new
        waiters = Set.new

        find_waiters thread, instances, waiters, stack

        waiters
      end

      private

      # @param [Thread] thread
      # @param [Array] managers
      # @param [Set] waiters
      # @param [Array] stack
      # @return [undefined]
      def find_waiters(thread, managers, waiters, stack)
        stack.push thread

        for manager in managers
          for lock in manager.internal_locks
            next unless lock.owned_by? thread

            for waiter in lock.waiters
              # Avoid infinite recursion in the case of an imminent deadlock
              next if stack.include? waiter

              # Skip waiters that are already known
              next unless waiters.add? waiter

              # Recursively find waiters for locks
              find_waiters waiter, managers, waiters, stack
            end
          end
        end

        stack.pop
      end
    end

    # @return [undefined]
    def initialize
      @locks = Hash.new
      @mutex = Mutex.new

      IdentifierLockManager.add self
    end

    # Returns true if the calling thread holds the lock for the given identifier
    #
    # @param [Object] identifier
    # @return [Boolean]
    def owned?(identifier)
      lock_available?(identifier) && lock_for(identifier).owned?
    end


    # Obtains a lock for the given identifier, blocking until the lock is obtained
    #
    # @param [Object] identifier
    # @return [undefined]
    def obtain_lock(identifier)
      loop do
        lock = lock_for identifier

        return if lock.lock
        remove_lock identifier, lock
      end
    end

    # Releases a lock for the given identifier
    #
    # @raise [RuntimeError] If no lock was ever obtained for the identifier
    # @param [Object] identifier
    # @return [undefined]
    def release_lock(identifier)
      unless lock_available? identifier
        raise RuntimeError
      end

      lock = lock_for identifier
      lock.unlock

      try_dispose identifier, lock
    end

    # @api private
    # @return [Array]
    def internal_locks
      @mutex.synchronize do
        @locks.values
      end
    end

    private

    # @param [Object] identifier
    # @param [DisposableLock] lock
    # @return [undefined]
    def try_dispose(identifier, lock)
      if lock.try_close
        remove_lock identifier, lock
      end
    end

    # @param [Object] identifier
    # @param [DisposableLock] lock
    # @return [undefined]
    def remove_lock(identifier, lock)
      @mutex.synchronize do
        @locks.delete_if do |i, l|
          i == identifier && l == lock
        end
      end
    end

    # @param [Object] identifier
    # @return [DisposableLock]
    def lock_for(identifier)
      @mutex.synchronize do
        if @locks.has_key? identifier
          @locks.fetch identifier
        else
          @locks.store identifier, DisposableLock.new
        end
      end
    end

    # @param [Object] identifier
    # @return [Boolean]
    def lock_available?(identifier)
      @mutex.synchronize do
        @locks.has_key? identifier
      end
    end
  end # IdentifierLockManager
end
