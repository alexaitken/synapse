module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures an event sourcing repository
      #
      # @see EventSourcingRepositoryDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def es_repository(identifier = nil, &block)
        with_definition_builder EventSourcingRepositoryDefinitionBuilder, identifier, &block
      end
    end # ContainerBuilder
  end # Configuration
end
