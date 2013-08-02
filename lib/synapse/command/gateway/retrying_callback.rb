module Synapse
  module Command
    # Implementation of a callback that will retry the dispatch of a command if execution results
    # in an exception
    #
    # This callback is not meant to be used directly. Use a command gateway implementation instead.
    class RetryingCallback < CommandCallback
      # @param [CommandCallback] delegate
      # @param [CommandMessage] command
      # @param [RetryScheduler] retry_scheduler
      # @param [CommandBus] command_bus
      # @return [undefined]
      def initialize(delegate, command, retry_scheduler, command_bus)
        @command = command
        @delegate = delegate
        @retry_scheduler = retry_scheduler

        @failures = Array.new
        @dispatcher = proc do
          command_bus.dispatch_with_callback command, self
        end
      end

      # @param [Object] result The result from the command handler
      # @return [undefined]
      def on_success(result)
        @delegate.on_success result
      end

      # @param [Exception] exception The cause of the failure
      # @return [undefined]
      def on_failure(exception)
        @failures.push exception

        begin
          unless exception.is_a?(RuntimeError) &&
              @retry_scheduler.schedule(@command, @failures, @dispatcher)
            @delegate.on_failure exception
          end
        rescue => exception
          @delegate.on_failure exception
        end
      end
    end # RetryingCallback
  end # Command
end
