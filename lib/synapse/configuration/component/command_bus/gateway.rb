module Synapse
  module Configuration
    # Definition builder used to create a command gateway
    #
    # @example The minimum possible effort to build a command gateway
    #   gateway
    #
    # @example Create a command gateway using an alternate command bus
    #   gateway :alt_gateway do
    #     use_command_bus :alt_command_bus
    #   end
    #
    # @todo Support for command filters and retry scheduler
    class CommandGatewayDefinitionBuilder < DefinitionBuilder
      # Changes the command bus that commands are sent from the gateway
      #
      # @param [Symbol] command_bus
      # @return [undefined]
      def use_command_bus(command_bus)
        @command_bus = command_bus
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :gateway

        use_command_bus :command_bus

        use_factory do
          command_bus = resolve @command_bus
          Command::CommandGateway.new command_bus
        end
      end
    end # CommandGatewayDefinitionBuilder
  end # Configuration
end
