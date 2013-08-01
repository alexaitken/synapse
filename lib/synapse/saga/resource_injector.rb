module Synapse
  module Saga
    # Represents a mechanism for injecting resources into saga instances
    class ResourceInjector
      # Injects required resources into the given saga instance
      #
      # @param [Saga] saga
      # @return [undefined]
      def inject_resources(saga); end
    end
  end
end
