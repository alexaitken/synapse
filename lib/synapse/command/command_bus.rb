module Synapse
  module Command
    # Represents a mechanism for dispatching commands to their appropriate handlers
    #
    # Command handlers can subscribe and unsubscribe to different command types. Only a single
    # handler can be subscribed for a command type at one time.
    #
    # Implementations can choose to dispatch commands in the calling thread or in another thread.
    class CommandBus
      include AbstractType

      # Dispatches the given command to the handler subscribed to its type
      #
      # @param [CommandMessage] command
      # @return [undefined]
      abstract_method :dispatch

      # Dispatches the given command to the handler subscribed to its type and notifies the
      # given callback of the outcome of the dispatch
      #
      # @param [CommandMessage] command
      # @param [CommandCallback] callback
      # @return [undefined]
      abstract_method :dispatch_with_callback

      # Subscribes the given handler to the given command type, replacing the currently subscribed
      # handler, if any.
      #
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [CommandHandler] The command handler being replaced, if any
      abstract_method :subscribe

      # Unsubscribes the given handler from the given command type, if it is currently subscribed
      # to the given command type.
      #
      # @param [Class] command_type
      # @param [CommandHandler] handler
      # @return [Boolean] True if command handler was unsubscribed from command handler
      abstract_method :unsubscribe
    end # CommandBus
  end # Command
end
