require 'spec_helper'

module Synapse
  module Configuration

    describe AsynchronousCommandBusDefinitionBuilder do
      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
        @builder.unit_factory
      end

      it 'builds with sensible defaults' do
        @builder.async_command_bus

        command_bus = @container.resolve :command_bus
        command_bus.should be_a(Command::AsynchronousCommandBus)

        thread_pool = command_bus.thread_pool
        thread_pool.should be_a(Contender::Pool::ThreadPoolExecutor)
        expect(thread_pool.active?).to be_true
        thread_pool.shutdown
      end

      it 'builds with a custom thread pool options' do
        @builder.async_command_bus do
          use_pool_options size: 4, non_block: true
        end

        command_bus = @container.resolve :command_bus

        thread_pool = command_bus.thread_pool
        expect(thread_pool.active?).to be_true
        thread_pool.shutdown
      end
    end

  end
end
