require 'spec_helper'

module Synapse
  module Command

    describe IntervalRetryScheduler do
      before do
        @interval = 5
        @max_retries = 3

        @provider = Object.new

        @scheduler = IntervalRetryScheduler.new @interval, @max_retries, @provider
        @command = CommandMessage.as_message Object.new
        @dispatcher = proc {}
      end

      it 'schedules up until the max number of retries' do
        failures = Array.new

        mock(@provider).schedule_dispatch(@interval, @dispatcher).times(@max_retries)

        @max_retries.times do
          failures.push RuntimeError.new
          @scheduler.schedule(@command, failures, @dispatcher).should be_true
        end

        failures.push RuntimeError.new
        @scheduler.schedule(@command, failures, @dispatcher).should be_false
      end

      it 'does not schedule if failure was explicitly non-transient' do
        failure = CommandValidationError.new
        @scheduler.schedule(@command, [failure], @dispatcher).should be_false
      end

      it 'does not schedule if cause of failure was explicitly non-transient' do
        failure = CommandExecutionError.new NonTransientError.new
        @scheduler.schedule(@command, [failure], @dispatcher).should be_false
      end
    end

  end
end
