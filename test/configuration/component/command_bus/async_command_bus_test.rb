require 'test_helper'

module Synapse
  module Configuration
    class AsynchronousCommandBusDefinitionFactoryTest < Test::Unit::TestCase
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      def test_simple
        @builder.unit_factory
        @builder.async_command_bus

        @command_bus = @container.resolve :command_bus
        assert @command_bus.is_a? Command::AsynchronousCommandBus
      end
    end
  end
end
