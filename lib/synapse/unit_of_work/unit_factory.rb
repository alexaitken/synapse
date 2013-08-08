module Synapse
  module UnitOfWork
    # Factory used to create unit of work instances
    class UnitFactory
      # @param [TransactionManager] transaction_manager
      # @return [undefined]
      def initialize(transaction_manager = nil)
        @transaction_manager = transaction_manager
      end

      # Creates and starts a new unit of work instance
      # @return [DefaultUnit]
      def create
        DefaultUnit.start @transaction_manager
      end
    end # UnitFactory
  end # UnitOfWork
end
