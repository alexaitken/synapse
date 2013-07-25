require 'synapse/configuration/component/command_bus/simple_command_bus'
require 'synapse/configuration/component/command_bus/gateway'

module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures a simple command bus
      builder :simple_command_bus, SimpleCommandBusDefinitionBuilder

      # Creates and configures a command gateway
      builder :gateway, CommandGatewayDefinitionBuilder
    end # ContainerBuilder
  end # Configuration
end
