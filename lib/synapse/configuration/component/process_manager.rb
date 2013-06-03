require 'synapse/configuration/component/process_manager/container_resource_injector'
require 'synapse/configuration/component/process_manager/generic_process_factory'
require 'synapse/configuration/component/process_manager/mapping_process_manager'

module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures a resource injector that uses the service container
      builder :container_resource_injector, ContainerResourceInjectorDefinitionBuilder

      # Creates and configures a generic process factory
      builder :process_factory, GenericProcessFactoryDefinitionBuilder

      # Creates and configures a mapping process manager
      builder :process_manager, MappingProcessManagerDefinitionBuilder
    end # ContainerBuilder
  end # Configuration
end
