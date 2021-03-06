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
      # @param [CommandMessage] command
      # @return [undefined]
      def dispatch(command)
        raise NotImplementedError
      end

      # Dispatches the given command to the handler subscribed to its type and notifies the
      # given callback of the outcome of the dispatch
      #
      # @abstract
      # @param [CommandMessage] command
      # @param [CommandCallback] callback
      # @return [undefined]
      def dispatch_with_callback(command, callback)
        raise NotImplementedError
      end

      # Subscribes the given handler to the given command type, replacing the currently subscribed
      # handler, if any.
      #
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [CommandHandler] The command handler being replaced, if any
      def subscribe(command_type, handler)
        raise NotImplementedError
      end

      # Unsubscribes the given handler from the given command type, if it is currently subscribed
      # to the given command type.
      #
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [Boolean] True if command handler was unsubscribed from command handler
      def unsubscribe(command_type, handler)
        raise NotImplementedError
      end
    end # CommandBus
  end # Command
end
