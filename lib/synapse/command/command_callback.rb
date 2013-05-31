module Synapse
  module Command
    # Callback that is notified of the outcome of the dispatch of a command
    class CommandCallback
      # Called when a dispatch is successful
      #
      # @param [Object] result The result from the command handler
      # @return [undefined]
      def on_success(result); end

      # Called when a dispatch fails due to an exception
      #
      # @param [Exception] exception The cause of the failure
      # @return [undefined]
      def on_failure(exception); end
    end # CommandCallback

    # Callback that provides a deferred result or exception from the execution of a command
    class FutureCallback < CommandCallback
      def initialize
        @mutex = Mutex.new
        @condition = ConditionVariable.new
      end

      # @raise [Exception] If an exception occured during command execution
      # @param [Float] timeout
      # @return [Object] The result from the command handler
      def result(timeout = nil)
        @mutex.synchronize do
          unless @dispatched
            @condition.wait @mutex, timeout
          end

          if @exception
            raise @exception
          end

          @result
        end
      end

      # @param [Object] result The result from the command handler
      # @return [undefined]
      def on_success(result)
        @mutex.synchronize do
          @dispatched = true
          @result = result

          @condition.broadcast
        end
      end

      # @param [Exception] exception The cause of the failure
      # @return [undefined]
      def on_failure(exception)
        @mutex.synchronize do
          @dispatched = true
          @exception = exception

          @condition.broadcast
        end
      end
    end # FutureCallback
  end # Command
end
