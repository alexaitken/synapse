module Synapse
  # Lock that tracks the thread owning the lock and any waiting threads
  class PublicLock
    # @return [Thread] The current owner of the thread, if any
    attr_reader :owner

    # @return [Array] The list of threads waiting for this lock
    attr_reader :waiting

    # @return [undefined]
    def initialize
      @mutex = Mutex.new
      @waiting = Array.new
    end

    # Returns true if the calling thread owns this lock
    #
    # @see Mutex#owned?
    # @return [Boolean]
    def owned?
      @owner == Thread.current
    end

    # Returns true if the given thread owns this lock
    # @return [Boolean]
    def owned_by?(thread)
      @owner == thread
    end

    # @see Mutex#synchronize
    # @return [undefined]
    def synchronize
      lock

      begin
        yield
      ensure
        unlock rescue nil
      end
    end

    # @see Mutex#lock
    # @return [undefined]
    def lock
      @mutex.synchronize do
        if @owner == Thread.current
          raise ThreadError, 'Lock is already owned by the current thread'
        end

        while @owner
          @waiting.push Thread.current

          begin
            @mutex.sleep
          ensure
            @waiting.delete Thread.current
          end
        end

        @owner = Thread.current
      end
    end

    # @see Mutex#unlock
    # @return [undefined]
    def unlock
      @mutex.synchronize do
        if @owner == Thread.current
          @owner = nil

          first = @waiting.shift
          first.wakeup if first
        else
          raise ThreadError, 'Lock is not owned by the current thread'
        end
      end
    end

    # @see Mutex#try_lock
    # @return [Boolean]]
    def try_lock
      @mutex.synchronize do
        if @owner == Thread.current
          raise ThreadError, 'Lock is already owned by the current thread'
        end

        if @owner
          return false
        end

        @owner = Thread.current
      end

      true
    end
  end
end
