module Synapse
  module Configuration
    # Definition builder used to create a generic process factory
    #
    # @example The minimum possible effort to build a process factory
    #   process_factory
    #
    # @example Use a custom resource injector
    #   process_factory :alt_process_factory do
    #     use_resource_injector :alt_resource_injector
    #   end
    class GenericProcessFactoryDefinitionBuilder < DefinitionBuilder
      # Changes the resource injector used by this process factory
      #
      # @see ProcessManager::ResourceInjector
      # @param [Symbol] resource_injector
      # @return [undefined]
      def use_resource_injector(resource_injector)
        @resource_injector = resource_injector
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :process_factory

        use_resource_injector :resource_injector

        use_factory do
          resource_injector = resolve @resource_injector, true

          process_factory = ProcessManager::GenericProcessFactory.new
          if resource_injector
            process_factory.resource_injector = resource_injector
          end

          process_factory
        end
      end
    end # GenericProcessFactoryDefinitionBuilder
  end # Configuration
end
