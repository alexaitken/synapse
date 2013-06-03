require 'test_helper'

module Synapse
  module Command

    class MappingCommandHandlerTest < Test::Unit::TestCase
      should 'pass the command to the correct mapped handler' do
        handler = ExampleMappingCommandHandler.new
        unit = Object.new

        command = CommandMessage.build do |builder|
          builder.payload = TestCommand.new
        end

        handler.handle command, unit
        assert handler.handled

        command = CommandMessage.build do |builder|
          builder.payload = TestSubCommand.new
        end

        handler.handle command, unit
        assert handler.sub_handled

        command = CommandMessage.build do |builder|
          builder.payload = 5
        end

        assert_raise ArgumentError do
          handler.handle command, unit
        end
      end

      should 'subscribe handler to the command bus for each mapped command type' do
        handler = ExampleMappingCommandHandler.new
        bus = Object.new

        mock(bus).subscribe(TestSubCommand, handler)
        mock(bus).subscribe(TestCommand, handler)

        handler.subscribe bus
      end

      should 'unsubscribe handler from the command bus for each mapped command type' do
        handler = ExampleMappingCommandHandler.new
        bus = Object.new

        mock(bus).unsubscribe(TestSubCommand, handler)
        mock(bus).unsubscribe(TestCommand, handler)

        handler.unsubscribe bus
      end
    end

    class TestCommand; end
    class TestSubCommand; end

    class ExampleMappingCommandHandler
      include MappingCommandHandler

      attr_accessor :handled, :sub_handled

      map_command TestCommand do |command|
        @handled = true
      end

      map_command TestSubCommand do |command|
        @sub_handled = true
      end
    end

  end
end
