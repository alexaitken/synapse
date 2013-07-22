require 'spec_helper'

module Synapse
  module Configuration

    describe UnitOfWorkFactoryDefinitionBuilder do
      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      it 'builds with sensible defaults' do
        txm = UnitOfWork::TransactionManager.new

        @builder.factory :transaction_manager do
          txm
        end
        @builder.unit_factory

        factory = @container.resolve :unit_factory
        factory.should be_a(UnitOfWork::UnitOfWorkFactory)
        factory.transaction_manager.should be(txm)
      end

      it 'builds with an alternate transaction manager' do
        txm = UnitOfWork::TransactionManager.new

        @builder.factory :alt_tx_manager do
          txm
        end
        @builder.unit_factory do
          use_transaction_manager :alt_tx_manager
        end

        factory = @container.resolve :unit_factory
        factory.transaction_manager.should be(txm)
      end

      it 'builds with an alternate unit of work provider' do
        @builder.factory :alt_unit_provider do
          UnitOfWork::UnitOfWorkProvider.new
        end
        @builder.unit_factory do
          use_unit_provider :alt_unit_provider
        end

        @container.resolve :unit_factory
      end
    end

  end
end
