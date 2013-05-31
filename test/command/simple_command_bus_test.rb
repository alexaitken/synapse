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

      should 'dispatch a command message to its registered handler' do
        handler = Object.new
        command = CommandMessage.build do |m|
          m.payload = TestCommand.new
        end

        mock(handler).handle(command, @unit)
        mock(@unit).commit

        @command_bus.subscribe TestCommand, handler
        @command_bus.dispatch command
      end

      should 'invoke a callback with the return value from a command handler' do
        handler = Object.new
        callback = Object.new
        command = CommandMessage.build do |m|
          m.payload = TestCommand.new
        end

        result = 123

        mock(handler).handle(command, @unit) do
          result
        end
        mock(callback).on_success(result)
        mock(@unit).commit

        @command_bus.subscribe TestCommand, handler
        @command_bus.dispatch_with_callback command, callback
      end

      should 'raise an exception when a dispatched command has no registered handler' do
        command = CommandMessage.build do |m|
          m.payload = TestCommand.new
        end

        callback = Object.new
        mock(callback).on_failure(is_a(NoHandlerError))

        @command_bus.dispatch_with_callback command, callback
      end

      should 'roll back the current unit of work if the command handler raises an exception' do
        handler = Object.new
        command = CommandMessage.build do |m|
          m.payload = TestCommand.new
        end

        exception = TypeError.new

        mock(handler).handle(command, @unit) do
          raise exception
        end

        mock(@logger).error(anything)
        mock(@unit).rollback(exception)

        @command_bus.subscribe TestCommand, handler

        callback = Object.new
        mock(callback).on_failure(is_a(CommandExecutionError))

        @command_bus.dispatch_with_callback command, callback
      end

      should 'commit the current unit of work if the command handler raises an exception' do
        handler = Object.new
        command = CommandMessage.build do |m|
          m.payload = TestCommand.new
        end

        exception = TypeError.new

        mock(handler).handle(command, @unit) do
          raise exception
        end

        rollback_policy = Object.new
        mock(rollback_policy).should_rollback(exception) do
          false
        end
        mock(@unit).commit

        @command_bus.rollback_policy = rollback_policy
        @command_bus.subscribe TestCommand, handler

        callback = Object.new
        mock(callback).on_failure(is_a(CommandExecutionError))

        @command_bus.dispatch_with_callback command, callback
      end

      should 'log when a subscribed handler is replaced' do
        handler = Object.new

        mock(@logger).debug(anything).ordered
        mock(@logger).info(anything).ordered

        @command_bus.subscribe TestCommand, handler
        @command_bus.subscribe TestCommand, handler
      end

      should 'log when a handler is unsubscribed' do
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
