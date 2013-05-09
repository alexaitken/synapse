require 'test_helper'

module Synapse
  module Command

    class WiringCommandHandlerTest < Test::Unit::TestCase
      def test_handle
        handler = ExampleWiringCommandHandler.new
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

      def test_subscribe
        handler = ExampleWiringCommandHandler.new
        bus = Object.new

        mock(bus).subscribe(TestSubCommand, handler)
        mock(bus).subscribe(TestCommand, handler)

        handler.subscribe bus
      end

      def test_unsubscribe
        handler = ExampleWiringCommandHandler.new
        bus = Object.new

        mock(bus).unsubscribe(TestSubCommand, handler)
        mock(bus).unsubscribe(TestCommand, handler)

        handler.unsubscribe bus
      end
    end

    class TestCommand; end
    class TestSubCommand; end

    class ExampleWiringCommandHandler
      include WiringCommandHandler

      attr_accessor :handled, :sub_handled

      wire TestCommand do |command|
        @handled = true
      end

      wire TestSubCommand do |command|
        @sub_handled = true
      end
    end

  end
end
