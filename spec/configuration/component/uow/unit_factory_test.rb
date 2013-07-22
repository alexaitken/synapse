require 'test_helper'

module Synapse
  module Configuration
    class UnitOfWorkFactoryDefinitionBuilderTest < Test::Unit::TestCase
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with sensible defaults' do
        @builder.factory :transaction_manager do
          UnitOfWork::TransactionManager.new
        end
        @builder.unit_factory

        factory = @container.resolve :unit_factory
        assert factory.is_a? UnitOfWork::UnitOfWorkFactory
        assert factory.transaction_manager
      end

      should 'build with an alternate transaction manager' do
        @builder.factory :alt_tx_manager do
          UnitOfWork::TransactionManager.new
        end
        @builder.unit_factory do
          use_transaction_manager :alt_tx_manager
        end

        factory = @container.resolve :unit_factory
        assert factory.transaction_manager
      end

      should 'build with an alternate unit of work provider' do
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
