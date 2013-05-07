module Synapse
  module ProcessManager
    # Represents a mechanism for determining correlations between events and process instances
    # @abstract
    class CorrelationResolver
      # Resolves a correlation from the given event
      #
      # @abstract
      # @param [EventMessage] event
      # @return [Correlation]
      def resolve(event); end
    end
  end
end
