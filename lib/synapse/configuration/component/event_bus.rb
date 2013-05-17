module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures a simple event bus
      #
      # @see SimpleEventBusDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def simple_event_bus(identifier = nil, &block)
        with_definition_builder SimpleEventBusDefinitionBuilder, identifier, &block
      end
    end # ContainerBuilder
  end # Configuration
end
