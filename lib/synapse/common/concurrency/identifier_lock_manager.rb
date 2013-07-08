module Synapse
  class IdentifierLockManager
    @mutex = Mutex.new
    @instances = Ref::WeakKeyMap.new

    class << self
      def instances
        @mutex.synchronize do
          @instances.keys
        end
      end

      def add(instance)
        @mutex.synchronize do
          @instances[instance] = true
        end
      end

      def waiters_for_locks_owned_by(thread)
        stack = Array.new
        waiters = Set.new

        find_waiters thread, instances, waiters, stack

        waiters
      end

    private

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

    def initialize
      @locks = Hash.new
      @mutex = Mutex.new

      IdentifierLockManager.add self
    end

    def owned?(identifier)
      lock_available?(identifier) && lock_for(identifier).owned?
    end

    def obtain_lock(identifier)
      loop do
        lock = lock_for identifier

        return if lock.lock
        remove_lock identifier, lock
      end
    end

    def release_lock(identifier)
      unless lock_available? identifier
        raise RuntimeError
      end

      lock = lock_for identifier
      lock.unlock

      try_dispose identifier, lock
    end

    # @api private
    def internal_locks
      @mutex.synchronize do
        @locks.values
      end
    end

  private

    def try_dispose(identifier, lock)
      if lock.try_close
        remove_lock identifier, lock
      end
    end

    def remove_lock(identifier, lock)
      @mutex.synchronize do
        @locks.delete_if do |i, l|
          i == identifier && l == lock
        end
      end
    end

    def lock_for(identifier)
      @mutex.synchronize do
        if @locks.has_key? identifier
          @locks.fetch identifier
        else
          @locks.store identifier, DisposableLock.new
        end
      end
    end

    def lock_available?(identifier)
      @mutex.synchronize do
        @locks.has_key? identifier
      end
    end
  end

  # @api private
  class DisposableLock
    attr_reader :closed

    alias_method :closed?, :closed

    attr_reader :hold_count
    attr_reader :owner
    attr_reader :waiters

    def initialize
      @mutex = Mutex.new

      @closed = false
      @hold_count = 0
      @owner = nil
      @waiters = Array.new
    end

    def owned?
      @owner == Thread.current
    end

    def owned_by?(thread)
      @owner == thread
    end

    def locked?
      @hold_count > 0
    end

    def lock
      @mutex.synchronize do
        unless owned?
          if @hold_count == 0
            @owner = Thread.current
          else
            @waiters.push Thread.current

            begin
              wait_for_lock
            ensure
              @waiters.delete Thread.current
            end

            return unless owned?
          end
        end

        @hold_count += 1
      end

      if closed?
        unlock
        return false
      end

      return true
    end

    def try_lock
      @mutex.synchronize do
        unless owned?
          if @hold_count == 0
            @owner = Thread.current
          else
            return false
          end
        end

        @hold_count += 1
        return true
      end
    end

    def unlock
      @mutex.synchronize do
        raise ArgumentError unless owned?

        @hold_count -= 1

        if @hold_count == 0
          @owner = nil
          wakeup_next_waiter
        end
      end
    end

    def try_close
      return false unless try_lock

      begin
        if @hold_count == 1
          @closed = true
          return true
        end

        return false
      ensure
        unlock
      end
    end

  private

    def check_for_deadlock
      return if owned?
      return unless locked?

      for waiter in IdentifierLockManager.waiters_for_locks_owned_by(Thread.current)
        if owned_by? waiter
          raise DeadlockError
        end
      end
    end

    # Mutex must be locked to perform this operation
    def wait_for_lock
      loop do
        if @hold_count == 0
          @owner = Thread.current
          return
        end

        check_for_deadlock
        @mutex.sleep 0.1 # Sleep for 100 milliseconds
      end
    end

    def wakeup_next_waiter
      begin
        n = @waiters.shift
        n.wakeup if n
      rescue ThreadError
        retry
      end
    end
  end
end

