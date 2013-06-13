module Synapse
  module Command
    # Command bus that uses a thread pool to asynchronously execute commands, invoking the given
    # callback when execution is completed or resulted in an error
    #
    # @todo Look into non-blocking circular buffers or LMAX Disruptor
    class AsynchronousCommandBus < SimpleCommandBus
      # Pool of worker threads that dispatch commands from a queue
      # @return [Contender::Pool::ThreadPoolExecutor]
      attr_accessor :thread_pool

      # @api public
      # @param [CommandMessage] command
      # @param [CommandCallback] callback
      # @return [undefined]
      def dispatch_with_callback(command, callback)
        @thread_pool.execute do
          super command, callback
        end
      end

      # Shuts down the command bus, waiting until all tasks are finished
      #
      # @api public
      # @return [undefined]
      def shutdown
        @thread_pool.shutdown
      end

      # Shuts down the command bus without waiting for tasks to finish
      #
      # @api public
      # @return [undefined]
      def shutdown!
        @thread_pool.shutdown!
      end
    end # AsynchronousCommandBus
  end # Command
end
