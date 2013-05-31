require 'test_helper'

module Synapse
  module Configuration
    class AsynchronousCommandBusDefinitionFactoryTest < Test::Unit::TestCase
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
        assert_equal 4, thread_pool.min
        assert_equal 4, thread_pool.max
      end

      should 'build with a custom thread pool size' do
        @builder.async_command_bus do
          use_threads 2, 8
        end

        command_bus = @container.resolve :command_bus

        thread_pool = command_bus.thread_pool
        assert_equal 2, thread_pool.min
        assert_equal 8, thread_pool.max
      end
    end
  end
end
