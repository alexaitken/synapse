module Synapse
  module Saga
    # Represents a mechanism for storing and loading saga instances
    # @abstract
    class SagaRepository
      # Returns a set of saga identifiers for sagas of the given type that have been
      # correlated with the given key value pair
      #
      # Sagaes that have been changed must be committed for changes to take effect
      #
      # @abstract
      # @param [Class] type
      # @param [Correlation] correlation
      # @return [Set]
      def find(type, correlation)
        raise NotImplementedError
      end

      # Loads a known saga by its unique identifier
      #
      # Sagaes that have been changed must be committed for changes to take effect
      #
      # Due to the concurrent nature of sagas, it is not unlikely for a saga to have
      # ceased to exist after it has been found based on correlations. Therefore, a repository
      # should gracefully handle a missing saga.
      #
      # @abstract
      # @param [String] id
      # @return [Saga] Returns nil if saga could not be found
      def load(id)
        raise NotImplementedError
      end

      # Commits the changes made to the saga instance
      #
      # If the committed saga is marked as inactive, it should delete the saga from the
      # underlying storage and remove all correlations for that saga.
      #
      # @abstract
      # @param [Saga] saga
      # @return [undefined]
      def commit(saga)
        raise NotImplementedError
      end

      # Registers a newly created saga with the repository
      #
      # Once a saga has been registered, it can be found using its correlations or by its
      # unique identifier.
      #
      # Note that if the added saga is marked as inactive, it will not be stored.
      #
      # @abstract
      # @param [Saga] saga
      # @return [undefined]
      def add(saga)
        raise NotImplementedError
      end
    end # SagaRepository
  end # Saga
end
