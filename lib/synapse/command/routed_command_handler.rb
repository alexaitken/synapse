module Synapse
  module Command
    # Base implementation of a command handler that provides the message routing DSL out of
    # the box
    module RoutedCommandHandler
      extend Concern
      include CommandHandler

      included do
        inheritable_accessor :command_router do
          Router.create_router
        end
      end

      module ClassMethods
        # @see MessageRouter#route
        # @param [Object...] args
        # @return [undefined]
        def route_command(*args, &block)
          command_router.route self, *args, &block
        end
      end

      # @param [CommandMessage] message
      # @param [Unit] current_unit
      # @return [Object]
      def handle(command, current_unit)
        handler = command_router.handler_for command

        unless handler
          raise ArgumentError, "No handler for command {#{command.payload_type}}"
        end

        handler.invoke self, command
      end
    end # RoutedCommandHandler
  end # Command
end
