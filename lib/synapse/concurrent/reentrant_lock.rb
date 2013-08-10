module Synapse
  module Concurrent
    # Simple implementation of a fair reentrant lock
    class ReentrantLock
      # @return [Thread]
      attr_reader :owner

      # @return [undefined]
      def initialize
        @mutex = Mutex.new
        @queue = Array.new # Guarded by mutex
        @hold_count = 0 # Guarded implicitly
      end

      # @return [undefined]
      def lock
        try_acquire || do_queued_acquire
      end

      def try_lock
        try_acquire
      end

      # @param [Integer] timeout
      # @return [Boolean]
      def try_timed_lock(timeout)
        try_acquire || do_timed_acquire(timeout)
      end

      # @raise [LockUsageError] If not owned by calling thread
      # @return [undefined]
      def unlock
        if try_release
          wakeup_successor
        end
      end

      # @return [Boolean]
      def locked?
        @hold_count > 0
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

      # @return [Integer]
      def hold_count
        return 0 unless owned?
        @hold_count
      end

      # @return [Array]
      def queued_threads
        synchronize { @queue.dup }
      end

      private

      # @return [Boolean]
      def try_acquire
        current = Thread.current

        synchronize {
          if @hold_count == 0
            if @queue.empty? || @queue.first == current
              @owner = current
              @hold_count = 1
              return true
            end

            # There are queued threads, do not preempt them
          elsif owned?
            @hold_count += 1
            return true
          end

          false
        }
      end

      # @raise [LockUsageError] If not owned by calling thread
      # @return [Boolean]
      def try_release
        unless owned?
          raise LockUsageError, 'Lock not owned by the calling thread'
        end

        @hold_count -= 1

        if @hold_count == 0
          @owner = nil
          return true
        end

        false
      end

      # @return [undefined]
      def do_queued_acquire
        current = Thread.current

        until try_acquire
          synchronize {
            @queue.push current
            @mutex.sleep
          }
        end
      ensure
        synchronize {
          @queue.delete current
        }
      end

      # @param [Integer] timeout
      # @return [Boolean]
      def do_timed_acquire(timeout)
        current = Thread.current
        last_time = Time.now

        until try_acquire
          return false if timeout <= 0

          synchronize {
            @queue.push current
            @mutex.sleep timeout
          }

          timeout -= Time.now - last_time
          last_time = Time.now
        end

        true
      ensure
        synchronize {
          @queue.delete current
        }
      end

      # @return [undefined]
      def wakeup_successor
        synchronize {
          begin
            s = @queue.first
            s.wakeup if s
          rescue ThreadError
            # Thread died during lock acquisition
            @queue.pop
            retry
          end
        }
      end

      # @yield
      # @return [undefined]
      def synchronize
        @mutex.synchronize { yield }
      end
    end # ReentrantLock
  end # Concurrent
end
