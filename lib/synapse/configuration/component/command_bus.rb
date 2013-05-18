module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures an asynchronous command bus
      #
      # @see AsynchronousCommandBusDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def simple_command_bus(identifier = nil, &block)
        with_definition_builder AsynchronousCommandBusDefinitionBuilder, identifier, &block
      end

      # Creates and configures a simple command bus
      #
      # @see SimpleCommandBusDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def simple_command_bus(identifier = nil, &block)
        with_definition_builder SimpleCommandBusDefinitionBuilder, identifier, &block
      end
    end # ContainerBuilder
  end # Configuration
end
