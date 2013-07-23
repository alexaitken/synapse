module Synapse
  module Command
    # Simplified interface to the command bus
    # @api public
    class CommandGateway
      # @return [RetryScheduler]
      attr_accessor :retry_scheduler

      # @param [CommandBus] command_bus
      # @param [Enumerable<CommandFilter>] filters
      # @return [undefined]
      def initialize(command_bus, filters)
        @command_bus = command_bus
        @filters = Array.new filters
      end

      # Fire and forget method of sending a command to the command bus
      #
      # If the given command is a bare object, it will be wrapped in a command message before
      # being dispatched on the command bus.
      #
      # @api public
      # @param [Object] command
      # @return [undefined]
      def send(command)
        send_with_callback command, VoidCallback.new
      end

      # Sends the given command
      #
      # If the given command is a bare object, it will be wrapped in a command message before
      # being dispatched on the command bus.
      #
      # @api public
      # @param [Object] command
      # @param [CommandCallback] callback
      # @return [undefined]
      def send_with_callback(command, callback)
        command = process_with_filters(CommandMessage.as_message(command))

        if @retry_scheduler
          callback = RetryingCallback.new callback, command, @retry_scheduler, @command_bus
        end

        @command_bus.dispatch_with_callback(command, callback)
      end

      # Sends the given command and blocks indefinitely until the result of the execution is
      # provided, the timeout is created or the thread is interrupted.
      #
      # If the given command is a bare object, it will be wrapped in a command message before
      # being dispatched on the command bus.
      #
      # @api public
      # @raise [CommandExecutionError] If an error occured while executing the command
      # @param [Object] command
      # @param [Float] timeout
      # @return [Object] The return value from the command handler
      def send_and_wait(command, timeout = nil)
        callback = FutureCallback.new
        send_with_callback command, callback
        callback.result timeout
      end

      protected

      # @param [CommandMessage] command
      # @return [CommandMessage] The message to dispatch
      def process_with_filters(command)
        @filters.reduce command do |intermediate, filter|
          filter.filter intermediate
        end
      end
    end # CommandGateway
  end # Command
end
