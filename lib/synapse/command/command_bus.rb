module Synapse
  module Command
    # Represents a mechanism for dispatching commands to their appropriate handlers
    #
    # Command handlers can subscribe and unsubscribe to different command types. Only a single
    # handler can be subscribed for a command type at one time.
    #
    # Implementations can choose to dispatch commands in the calling thread or in another thread.
    #
    # @abstract
    class CommandBus
      # Dispatches the given command to the handler subscribed to its type
      #
      # @abstract
      # @raise [CommandExecutionError]
      #   If an error occurs during the handling of the command
      # @raise [NoHandlerError]
      #   If no handler is subscribed that is capable of handling the command
      # @param [CommandMessage] command
      # @return [undefined]
      def dispatch(command); end

      # Subscribes the given handler to the given command type, replacing the currently subscribed
      # handler, if any.
      #
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [undefined]
      def subscribe(command_type, handler); end

      # Unsubscribes the given handler from the given command type, if it is currently subscribed
      # to the given command type.
      #
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [undefined]
      def unsubscribe(command_type, handler); end
    end
  end
end