module Synapse
  module Configuration
    class ContainerBuilder
      initializer do
        # Configures the default unit of work provider implementation
        factory :unit_provider do
          UnitOfWork::UnitOfWorkProvider.new
        end
      end

      # @see UnitOfWorkFactoryDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def unit_factory(identifier = nil, &block)
        with_definition_builder UnitOfWorkFactoryDefinitionBuilder, identifier, &block
      end
    end # ContainerBuilder
  end # Configuration
end
