require 'spec_helper'
require 'eventmachine'

module Synapse
  module Command

    describe IntervalRetryScheduler do
      before do
        @maxRetries = 3

        @scheduler = IntervalRetryScheduler.new 5.0, @maxRetries
        @command = CommandMessage.as_message Object.new
        @dispatcher = proc {}
      end

      it 'schedules up until the max number of retries' do
        failures = Array.new

        mock(EventMachine).add_timer(5.0, &@dispatcher).times(@maxRetries)

        @maxRetries.times do
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
