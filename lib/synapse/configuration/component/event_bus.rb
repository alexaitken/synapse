require 'synapse/configuration/component/event_bus/simple_event_bus'

module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures a simple event bus
      builder :simple_event_bus, SimpleEventBusDefinitionBuilder
    end # ContainerBuilder
  end # Configuration
end
