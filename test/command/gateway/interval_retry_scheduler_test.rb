require 'test_helper'
require 'eventmachine'

module Synapse
  module Command
    class IntervalRetrySchedulerTest < Test::Unit::TestCase

      def setup
        @scheduler = IntervalRetryScheduler.new 5.0, 3
        @command = CommandMessage.as_message Object.new
        @dispatcher = proc {}
      end

      should 'schedule up until the max number of retries' do
        failures = []

        x = 3

        mock(EventMachine).add_timer(5.0, &@dispatcher).times(3)

        x.times do
          failures.push RuntimeError.new
          assert @scheduler.schedule @command, failures, @dispatcher
        end

        failures.push RuntimeError.new
        refute @scheduler.schedule @command, failures, @dispatcher
      end

      should 'not schedule if failure was explicitly non-transient' do
        failure = CommandValidationError.new
        refute @scheduler.schedule @command, [failure], @dispatcher
      end

      should 'not schedule if cause of failure was explicitly non-transient' do
        failure = CommandExecutionError.new NonTransientError.new
        refute @scheduler.schedule @command, [failure], @dispatcher
      end

    end # IntervalRetrySchedulerTest
  end # Command
end
