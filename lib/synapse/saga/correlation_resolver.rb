module Synapse
  module Saga
    # Represents a mechanism for determining correlations between events and saga instances
    # @see SagaManager
    class CorrelationResolver
      include AbstractType

      # Resolves a correlation from the given event
      #
      # @param [EventMessage] event
      # @return [Correlation]
      abstract_method :resolve
    end # CorrelationResolver
  end # Saga
end
