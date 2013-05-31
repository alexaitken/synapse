module Synapse
  module Command
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
          unless exception.is_a? RuntimeError and
              @retry_scheduler.schedule @command, @failures, @dispatcher
            @delegate.on_failure exception
          end
        rescue
          @delegate.on_failure $!
        end
      end
    end # RetryingCallback
  end # Command
end
