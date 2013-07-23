module Synapse
  module Configuration
    # Definition builder used to create a resource injector that uses the service container
    #
    # @example The minimum possible effort to build a resource injector
    #   container_resource_injector
    class ContainerResourceInjectorDefinitionBuilder < DefinitionBuilder
      # No options available for this definition builder

      protected

      # @return [undefined]
      def populate_defaults
        identified_by :resource_injector

        use_factory do
          ProcessManager::ContainerResourceInjector.new @container
        end
      end
    end # ContainerResourceInjectorDefinitionBuilder
  end # Configuration
end
