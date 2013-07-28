require 'spec_helper'

module Synapse
  module Command

    describe AsynchronousCommandBus do
      let :unit_provider do
        UnitOfWork::UnitOfWorkProvider.new
      end

      let :unit_factory do
        UnitOfWork::UnitOfWorkFactory.new unit_provider
      end

      let :message do
        CommandMessage.build do |builder|
          builder.payload = TestAsyncCommand.new
        end
      end

      it 'defers command dispatch to an executor service' do
        executor = Object.new

        mock(executor).execute do |block|
          block.call
        end

        handler = Object.new
        mock(handler).handle(message, anything)

        bus = AsynchronousCommandBus.new unit_factory, executor
        bus.subscribe TestAsyncCommand, handler
        bus.dispatch message
      end

      it 'integrates with a pool executor' do
        executor = Contender.fixed_pool 4
        x = 10

        latch = Contender::CountdownLatch.new x
        handler = TestAsyncHandler.new latch

        bus = AsynchronousCommandBus.new unit_factory, executor
        bus.subscribe TestAsyncCommand, handler

        x.times do
          bus.dispatch message
        end

        latch.await
        bus.shutdown
      end
    end

    class TestAsyncCommand
    end

    class TestAsyncHandler
      def initialize(latch)
        @latch = latch
      end

      def handle(command, current_unit)
        @latch.countdown
      end
    end

  end
end
