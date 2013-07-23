require 'spec_helper'

module Synapse
  module Command

    describe AsynchronousCommandBus do
      before do
        unit_provider = UnitOfWork::UnitOfWorkProvider.new
        unit_factory = UnitOfWork::UnitOfWorkFactory.new unit_provider

        @bus = AsynchronousCommandBus.new unit_factory
        @bus.thread_pool = Contender::Pool::ThreadPoolExecutor.new
        @bus.thread_pool.start
      end

      it 'dispatches commands asynchronously using a thread pool' do
        x = 5 # Number of commands to dispatch

        command = CommandMessage.as_message TestCommand.new
        latch = Contender::CountdownLatch.new x
        handler = TestAsyncHandler.new latch

        @bus.subscribe TestCommand, handler

        x.times do
          @bus.dispatch command
        end

        latch.await

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
