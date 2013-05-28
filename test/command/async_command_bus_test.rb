require 'test_helper'
require 'support/countdown_latch'

module Synapse
  module Command
    class AsynchronousCommandBusTest < Test::Unit::TestCase
      def setup
        unit_provider = UnitOfWork::UnitOfWorkProvider.new
        unit_factory = UnitOfWork::UnitOfWorkFactory.new unit_provider

        @bus = AsynchronousCommandBus.new unit_factory
        @bus.thread_pool = Thread.pool 2
      end

      def test_dispatch
        x = 10 # Number of commands to dispatch

        command = CommandMessage.as_message TestCommand.new
        callback = Object.new
        handler = TestAsyncHandler.new x

        @bus.subscribe TestCommand, handler

        @latch = CountdownLatch.new x

        mock(callback).on_success(anything).any_times do
          @latch.countdown!
        end

        x.times do
          @bus.dispatch_with_callback command, callback
        end

        wait_until 10 do
          @latch.count == 0 and handler.latch.count == 0
        end

        @bus.shutdown
      end
    end

    class TestCommand; end

    class TestAsyncHandler
      attr_reader :latch

      def initialize(x)
        @latch = CountdownLatch.new x
      end

      def handle(command, unit)
        @latch.countdown!
      end
    end
  end
end
