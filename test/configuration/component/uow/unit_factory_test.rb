require 'test_helper'

module Synapse
  module Configuration
    class UnitOfWorkFactoryDefinitionBuilderTest < Test::Unit::TestCase
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      def test_default
        @builder.factory :transaction_manager do
          UnitOfWork::TransactionManager.new
        end
        @builder.unit_factory

        factory = @container.resolve :unit_factory
        assert factory.is_a? UnitOfWork::UnitOfWorkFactory
        assert factory.transaction_manager
      end

      def test_tx_manager
        @builder.factory :alt_tx_manager do
          UnitOfWork::TransactionManager.new
        end
        @builder.unit_factory do
          use_transaction_manager :alt_tx_manager
        end

        factory = @container.resolve :unit_factory
        assert factory.transaction_manager
      end

      def test_unit_provider
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
