module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures a simple repository
      #
      # @see SimpleRepositoryDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def simple_repository(identifier = nil, &block)
        with_definition_builder SimpleRepositoryDefinitionBuilder, identifier, &block
      end
    end # ContainerBuilder
  end # Configuration
end
