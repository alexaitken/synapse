module Synapse
  module UnitOfWork
    # Represents a mechanism for a unit of work to integrate with an underlying transaction
    # management system
    #
    # @abstract
    class TransactionManager
      # Creates and returns a transaction for use by the unit of work
      #
      # @abstract
      # @return [Object]
      def start; end

      # Commits the given transaction
      #
      # @param [Object] transaction
      # @return [undefined]
      def commit(transaction); end

      # Rolls back the given transaction
      #
      # @param [Object] transaction
      # @return [undefined]
      def rollback(transaction); end
    end
  end
end
