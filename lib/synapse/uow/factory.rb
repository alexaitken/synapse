module Synapse
  module UnitOfWork
    # Factory that creates and configures new unit of work instances
    class UnitOfWorkFactory
      # @return [TransactionManager]
      attr_accessor :transaction_manager

      # @param [UnitOfWorkProvider] provider
      # @return [undefined]
      def initialize(provider)
        @provider = provider
      end

      # Creates and starts a unit of work
      # @return [UnitOfWork]
      def create
        uow = UnitOfWork.new @provider

        if @transaction_manager
          uow.transaction_manager = @transaction_manager
        end

        uow.start
        uow
      end
    end
  end
end
