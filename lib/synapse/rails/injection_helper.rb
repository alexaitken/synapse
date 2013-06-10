module Synapse
  module Rails
    # Mixin for an action controller in Rails that adds dependency injection
    module InjectionHelper
      extend ActiveSupport::Concern

      included do
        before_filter :inject_dependencies
      end

      # Performs one-time dependency injection before an action is called
      # @return [undefined]
      def inject_dependencies
        return if @_dependencies_injected

        container = Synapse.container
        container.inject_into self

        @_dependencies_injected = true
      end
    end # InjectionHelper
  end # Rails
end
