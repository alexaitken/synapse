module Synapse
  module Command
    # Implementation of a retry scheduler that retries commands at regular intervals
    #
    # If the last failure is explicitly non-transient exception or the number of failures reaches
    # the maximum number of retries, the command will not be scheduled for retry.
    #
    # This implementation uses EventMachine to schedule one-shot timers.
    class IntervalRetryScheduler < RetryScheduler
      # @param [Float] interval
      # @param [Integer] max_retries
      # @return [undefined]
      def initialize(interval, max_retries)
        @interval = interval
        @max_retries = max_retries

        @logger = Logging.logger[self.class]
      end

      # @param [CommandMessage] command
      # @param [Array<Exception>] failures
      # @param [Proc] dispatcher
      # @return [Boolean]
      def schedule(command, failures, dispatcher)
        lastFailure = failures.last

        if explicitly_non_transient? lastFailure
          @logger.info 'Dispatch of command [%s] [%s] resulted in non-transient exception' %
            [command.payload_type, command.id]

          return false
        end

        failureCount = failures.size

        if failureCount > @max_retries
          @logger.info 'Dispatch of command [%s] [%s] resulted in exception [%s] times' %
            [command.payload_type, command.id, failureCount]

          return false
        end

        if @logger.info?
          @logger.info 'Dispatch of command [%s] [%s] resulted in exception; will retry up to [%s] more times' %
            [command.payload_type, command.id, @max_retries - failureCount]
        end

        perform_schedule command, dispatcher

        true
      end

    private

      # @param [Exception] exception
      # @return [Boolean]
      def explicitly_non_transient?(exception)
        return true if exception.is_a? NonTransientError

        if exception.respond_to? :cause
          explicitly_non_transient? exception.cause
        else
          false
        end
      end

      # @param [CommandMessage] command
      # @param [Proc] dispatcher
      # @return [undefined]
      def perform_schedule(command, dispatcher)
        EventMachine.add_timer @interval, &dispatcher
      end
    end # IntervalRetryScheduler
  end # Command
end
