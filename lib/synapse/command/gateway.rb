module Synapse
  module Command
    # Simplified interface to the command bus
    class CommandGateway
      # @param [CommandBus] command_bus
      # @return [undefined]
      def initialize(command_bus)
        @command_bus = command_bus
      end

      # Fire and forget method of sending a command to the command bus
      #
      # @param [Object] command
      # @return [undefined]
      def send(command)
        @command_bus.dispatch(CommandMessage.as_message(command))
      end
    end
  end
end
