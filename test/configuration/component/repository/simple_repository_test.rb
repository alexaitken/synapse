require 'test_helper'

module Synapse
  module Configuration
    class SimpleRepositoryDefinitionBuilderTest < Test::Unit::TestCase

      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with sensible defaults' do
        # Repository needs unit of work provider (initialized by default)
        # Repository needs event bus
        @builder.simple_event_bus

        # SimpleRepository needs an aggregate type
        @builder.simple_repository :account_repository do
          use_aggregate_type Object
        end

        repository = @container.resolve :account_repository

        event_bus = @container.resolve :event_bus
        unit_provider = @container.resolve :unit_provider

        assert_same event_bus, repository.event_bus
        assert_same unit_provider, repository.unit_provider

        assert_instance_of Repository::PessimisticLockManager, repository.lock_manager
      end

    end
  end
end
