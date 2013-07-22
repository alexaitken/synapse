require 'test_helper'

module Synapse
  module Command
    class AsynchronousCommandBusTest < Test::Unit::TestCase
      def setup
        unit_provider = UnitOfWork::UnitOfWorkProvider.new
        unit_factory = UnitOfWork::UnitOfWorkFactory.new unit_provider

        @bus = AsynchronousCommandBus.new unit_factory
        @bus.thread_pool = Contender::Pool::ThreadPoolExecutor.new
        @bus.thread_pool.start
      end

      should 'be able to dispatch commands asynchronously using a thread pool' do
        x = 5 # Number of commands to dispatch

        command = CommandMessage.as_message TestCommand.new
        latch = Contender::CountdownLatch.new x
        handler = TestAsyncHandler.new latch

        @bus.subscribe TestCommand, handler

        x.times do
          @bus.dispatch command
        end

        assert latch.await 5

        @bus.shutdown
      end
    end

    class TestAsyncHandler
      def initialize(latch)
        @latch = latch
      end

      def handle(command, unit)
        @latch.countdown
      end
    end

    class TestCommand; end
  end
end
