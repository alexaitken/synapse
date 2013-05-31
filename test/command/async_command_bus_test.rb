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

      should 'be able to dispatch commands asynchronously using a thread pool' do
        x = 5 # Number of commands to dispatch

        command = CommandMessage.as_message TestCommand.new
        handler = TestAsyncHandler.new x

        @bus.subscribe TestCommand, handler

        x.times do
          @bus.dispatch command
        end

        wait_until do
          handler.latch.count == 0
        end

        @bus.shutdown
      end
    end

    class TestAsyncHandler
      attr_reader :latch

      def initialize(x)
        @latch = CountdownLatch.new x
      end

      def handle(command, unit)
        @latch.countdown!
      end
    end

    class TestCommand; end
  end
end
