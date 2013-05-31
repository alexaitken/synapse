module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures an upcaster chain
      #
      # @see UpcasterChainDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def upcaster_chain(identifier = nil, &block)
        with_definition_builder UpcasterChainDefinitionBuilder, identifier, &block
      end
    end # ContainerBuilder
  end # Configuration
end
