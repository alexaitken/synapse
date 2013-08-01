module Synapse
  module Saga
    # Represents a mechanism for determining correlations between events and saga instances
    # @abstract
    class CorrelationResolver
      # Resolves a correlation from the given event
      #
      # @abstract
      # @param [EventMessage] event
      # @return [Correlation]
      def resolve(event)
        raise NotImplementedError
      end
    end # CorrelationResolver
  end # Saga
end
