require 'test_helper'

module Synapse
  module Command

    class SimpleCommandBusTest < Test::Unit::TestCase
      def setup
        @unit_factory = Object.new
        @unit = Object.new
        @command_bus = SimpleCommandBus.new @unit_factory
        @logger = Logging.logger[@command_bus.class]

        mock(@unit_factory).create.any_times do
          @unit
        end
      end

      def test_dispatch
        handler = Object.new
        command = CommandMessage.new do |m|
          m.payload = TestCommand.new
        end

        mock(handler).handle(command, @unit)
        mock(@unit).commit

        @command_bus.subscribe TestCommand, handler
        @command_bus.dispatch command
      end

      def test_dispatch_no_handler
        command = CommandMessage.new do |m|
          m.payload = TestCommand.new
        end

        assert_raise NoHandlerError do
          @command_bus.dispatch command
        end
      end

      def test_dispatch_rollback_on_execution
        handler = Object.new
        command = CommandMessage.new do |m|
          m.payload = TestCommand.new
        end

        exception = TypeError.new

        mock(handler).handle(command, @unit) do
          raise exception
        end

        mock(@logger).error(anything)
        mock(@unit).rollback(exception)

        @command_bus.subscribe TestCommand, handler

        assert_raise CommandExecutionError do
          @command_bus.dispatch command
        end
      end

      def test_subscribe
        handler = Object.new

        mock(@logger).debug(anything).ordered
        mock(@logger).info(anything).ordered

        @command_bus.subscribe TestCommand, handler
        @command_bus.subscribe TestCommand, handler
      end

      def test_unsubscribe
        handler_a = Object.new
        handler_b = Object.new

        mock(@logger).info(anything).ordered # not subscribed to anyone
        mock(@logger).debug(anything).ordered # now subscribed
        mock(@logger).info(anything).ordered # subscribed to different
        mock(@logger).debug(anything).ordered # now unsubscribed

        @command_bus.unsubscribe TestCommand, handler_a
        @command_bus.subscribe TestCommand, handler_a
        @command_bus.unsubscribe TestCommand, handler_b
        @command_bus.unsubscribe TestCommand, handler_a
      end
    end

    class TestCommand; end
    class TestOtherCommand; end

  end
end
