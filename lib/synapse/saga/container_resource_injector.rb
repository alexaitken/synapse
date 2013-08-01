module Synapse
  module Saga
    # Resource injector that uses the service container and dependency DSL to inject resources
    class ContainerResourceInjector < ResourceInjector
      # @param [Configuration::Container] container
      # @return [undefined]
      def initialize(container)
        @container = container
      end

      # @param [Saga] saga
      # @return [undefined]
      def inject_resources(saga)
        @container.inject_into saga
      end
    end # ContainerResourceInjector
  end # Saga
end
