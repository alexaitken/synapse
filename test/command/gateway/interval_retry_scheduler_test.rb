require 'test_helper'
require 'eventmachine'

module Synapse
  module Command
    class IntervalRetrySchedulerTest < Test::Unit::TestCase

      def setup
        @scheduler = IntervalRetryScheduler.new 0.25, 2
        @command = CommandMessage.as_message Object.new
        @dispatcher = proc {}
      end

      should 'schedule up until the max number of retries' do
        failures = []

        EventMachine.run do
          x = 2
          latch = CountdownLatch.new x

          @dispatcher = proc do
            latch.countdown!
            if latch.count == 0
              EventMachine.stop_event_loop
            end
          end

          x.times do
            failures.push RuntimeError.new
            assert @scheduler.schedule @command, failures, @dispatcher
          end

          EventMachine.add_timer 5 do
            fail 'Operation timed out'
          end

          # Now we wait and pray that EventMachine does timers correctly
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
