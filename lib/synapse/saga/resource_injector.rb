module Synapse
  module Saga
    # Represents a mechanism for injecting resources into saga instances
    class ResourceInjector
      include AbstractType

      # Injects required resources into the given saga instance
      #
      # @param [Saga] saga
      # @return [undefined]
      abstract_method :inject_into
    end # ResourceInjector
  end # Saga
end
