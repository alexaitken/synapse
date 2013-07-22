require 'test_helper'

module Synapse
  module Configuration
    describe AsynchronousCommandBusDefinitionFactory do
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
        @builder.unit_factory
      end

      should 'build with sensible defaults' do
        @builder.async_command_bus

        command_bus = @container.resolve :command_bus
        assert command_bus.is_a? Command::AsynchronousCommandBus

        thread_pool = command_bus.thread_pool
        assert_instance_of Contender::Pool::ThreadPoolExecutor, thread_pool
        assert thread_pool.active?
        thread_pool.shutdown
      end

      should 'build with a custom thread pool options' do
        @builder.async_command_bus do
          use_pool_options size: 4, non_block: true
        end

        command_bus = @container.resolve :command_bus

        thread_pool = command_bus.thread_pool
        assert thread_pool.active?
        thread_pool.shutdown
      end
    end
  end
end
