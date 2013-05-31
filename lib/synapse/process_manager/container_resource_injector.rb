module Synapse
  module ProcessManager
    # Resource injector that uses the service container and dependency DSL to inject resources
    class ContainerResourceInjector < ResourceInjector
      # @param [Configuration::Container] container
      # @return [undefined]
      def initialize(container)
        @container = container
      end

      # @param [Process] process
      # @return [undefined]
      def inject_resources(process)
        @container.inject_into process
      end
    end # ContainerResourceInjector
  end # ProcessManager
end
