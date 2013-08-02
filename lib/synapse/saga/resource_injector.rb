module Synapse
  module Saga
    # Represents a mechanism for injecting resources into saga instances
    # @abstract
    class ResourceInjector
      # Injects required resources into the given saga instance
      #
      # @abstract
      # @param [Saga] saga
      # @return [undefined]
      def inject_resources(saga)
        raise NotImplementedError
      end
    end # ResourceInjector

    # Implementation of a resource injector that does nothing
    class NullResourceInjector < ResourceInjector
      # @param [Saga] saga
      # @return [undefined]
      def inject_resources(saga)
        # This method is intentionally empty
      end
    end # NullResourceInjector
  end # Saga
end
