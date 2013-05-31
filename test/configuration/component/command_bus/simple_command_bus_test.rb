require 'test_helper'

module Synapse
  module Configuration
    class SimpleCommandBusDefinitionFactoryTest < Test::Unit::TestCase
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with sensible defaults' do
        @builder.unit_factory
        @builder.simple_command_bus

        command_bus = @container.resolve :command_bus
        assert command_bus.is_a? Command::SimpleCommandBus
      end

      should 'build with an alternate unit of work factory' do
        @builder.unit_factory :alt_unit_factory
        @builder.simple_command_bus do
          use_unit_factory :alt_unit_factory
        end

        command_bus = @container.resolve :command_bus
      end

      should 'build and register tagged command handlers' do
        handler_a = Object.new
        handler_b = Object.new

        @builder.definition :first_handler do
          tag :command_handler
          use_instance handler_a
        end

        @builder.definition :second_handler do
          tag :alt_command_handler
          use_instance handler_b
        end

        @builder.unit_factory
        @builder.simple_command_bus

        @builder.simple_command_bus :alt_command_bus do
          use_handler_tag :alt_command_handler
        end

        mock(handler_a).subscribe(is_a(Command::SimpleCommandBus))
        command_bus = @container.resolve :command_bus

        mock(handler_b).subscribe(is_a(Command::SimpleCommandBus))
        command_bus = @container.resolve :alt_command_bus
      end
    end
  end
end
