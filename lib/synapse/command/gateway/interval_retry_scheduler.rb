module Synapse
  module Command
    # Implementation of a retry scheduler that retries commands at regular intervals
    #
    # If the last failure is explicitly non-transient exception or the number of failures reaches
    # the maximum number of retries, the command will not be scheduled for retry.
    #
    # This implementation uses EventMachine to schedule one-shot timers.
    class IntervalRetryScheduler < RetryScheduler
      include Loggable

      # @param [Float] interval
      # @param [Integer] max_retries
      # @param [ScheduleProvider] schedule_provider
      # @return [undefined]
      def initialize(interval, max_retries, schedule_provider)
        @interval = interval
        @max_retries = max_retries
        @schedule_provider = schedule_provider
      end

      # @param [CommandMessage] command
      # @param [Array] failures
      # @param [Proc] dispatcher
      # @return [Boolean]
      def schedule(command, failures, dispatcher)
        if explicitly_non_transient? failures.last
          logger.info "Dispatch of command {#{command.payload_type}} {#{command.id}} " +
            "resulted in a non-transient exception"

          return false
        end

        failure_count = failures.size

        if failure_count > @max_retries
          logger.info "Dispatch of command {#{command.payload_type}} {#{command.id}} " +
            "resulted in an exception #{failure_count} times"

          return false
        end

        if logger.info?
          retries_left = @max_retries - failure_count

          logger.info "Dispatch of command {#{command.payload_type}} {#{command.id}} " +
            "resulted in an exception; will retry up to #{retries_left} more times"
        end

        @schedule_provider.schedule_dispatch @interval, dispatcher

        true
      end

      private

      # @param [Exception] exception
      # @return [Boolean]
      def explicitly_non_transient?(exception)
        if exception.is_a? NonTransientError
          true
        elsif exception.respond_to? :cause
          explicitly_non_transient? exception.cause
        else
          false
        end
      end
    end # IntervalRetryScheduler
  end # Command
end
