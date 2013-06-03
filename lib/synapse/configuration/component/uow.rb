require 'synapse/configuration/component/uow/unit_factory'

module Synapse
  module Configuration
    class ContainerBuilder
      initializer do
        # Configures the default unit of work provider implementation
        factory :unit_provider do
          UnitOfWork::UnitOfWorkProvider.new
        end
      end

      # Creates and configures a unit of work factory
      builder :unit_factory, UnitOfWorkFactoryDefinitionBuilder
    end # ContainerBuilder
  end # Configuration
end
