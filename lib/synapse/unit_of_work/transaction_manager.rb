module Synapse
  module UnitOfWork
    # Represents a mechanism for a unit of work to integrate with an underlying transaction
    # management system
    class TransactionManager
      include AbstractType

      # Creates and returns a transaction for use by the unit of work
      # @return [Object]
      abstract_method :start

      # Commits the given transaction
      #
      # @param [Object] transaction
      # @return [undefined]
      abstract_method :commit

      # Rolls back the given transaction
      #
      # @param [Object] transaction
      # @return [undefined]
      abstract_method :rollback
    end # TransactionManager
  end # UnitOfWork
end
