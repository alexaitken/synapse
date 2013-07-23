module Synapse
  module Configuration
    # Definition builder used to create a unit of work factory
    #
    # @example The minimum possible effort to build a unit of work factory
    #   unit_factory
    #
    # @example Create a factory with a specific unit provider and tx manager
    #   unit_factory :alt_unit_factory do
    #     use_transaction_manager :sequel_tx_manager
    #     use_unit_provider :alt_unit_provider
    #   end
    class UnitOfWorkFactoryDefinitionBuilder < DefinitionBuilder
      # Changes the transaction manager to use when creating units of work
      #
      # @see UnitOfWork::TransactionManager
      # @param [Symbol] tx_manager
      # @return [undefined]
      def use_transaction_manager(tx_manager)
        @tx_manager = tx_manager
      end

      # Changes the unit of work provider to use when creating units of work
      #
      # @see UnitOfWork::UnitOfWorkProvider
      # @param [Symbol] unit_provider
      # @return [undefined]
      def use_unit_provider(unit_provider)
        @unit_provider = unit_provider
      end

      protected

      # @return [undefined]
      def populate_defaults
        identified_by :unit_factory

        use_transaction_manager :transaction_manager
        use_unit_provider :unit_provider

        use_factory do
          tx_manager = resolve @tx_manager, true
          unit_provider = resolve @unit_provider

          unit_factory = UnitOfWork::UnitOfWorkFactory.new unit_provider
          unit_factory.transaction_manager = tx_manager

          unit_factory
        end
      end
    end # UnitOfWorkFactoryDefinitionBuilder
  end # Configuration
end
