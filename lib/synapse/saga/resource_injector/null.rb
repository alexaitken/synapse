module Synapse
  module Saga
    # Implementation of a resource injector that does nothing
    class NullResourceInjector < ResourceInjector
      # @return [undefined]
      def inject_into(*)
        # This method is intentionally empty
      end
    end # NullResourceInjector
  end # Saga
end
