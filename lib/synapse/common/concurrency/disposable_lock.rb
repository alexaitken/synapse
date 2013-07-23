module Synapse
  # @api private
  class DisposableLock
    # @return [Boolean]
    attr_reader :closed

    alias_method :closed?, :closed

    # @return [Thread]
    attr_reader :owner

    # @return [Array]
    attr_reader :waiters

    # @return [undefined]
    def initialize
      @mutex = Mutex.new

      @closed = false
      @hold_count = 0
      @owner = nil
      @waiters = Array.new
    end

    # @return [Boolean]
    def owned?
      @owner == Thread.current
    end

    # @param [Thread] thread
    # @return [Boolean]
    def owned_by?(thread)
      @owner == thread
    end

    # @return [Boolean]
    def locked?
      @hold_count > 0
    end

    # @return [Boolean] False if lock has been closed
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
        false
      else
        true
      end
    end

    # @return [Boolean]
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

    # @raise [RuntimeError] If caller does not own the lock
    # @return [undefined]
    def unlock
      @mutex.synchronize do
        raise RuntimeError unless owned?

        @hold_count -= 1

        if @hold_count == 0
          @owner = nil
          wakeup_next_waiter
        end
      end
    end

    # @return [Boolean] True if lock was closed
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

    # @raise [DeadlockError]
    # @return [undefined]
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
    # @return [undefined]
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

    # @return [undefined]
    def wakeup_next_waiter
      n = @waiters.shift
      n.wakeup if n
    rescue ThreadError
      retry
    end
  end # DisposableLock
end
