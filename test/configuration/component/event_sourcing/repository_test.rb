require 'test_helper'

module Synapse
  module Configuration
    class EventSourcingRepositoryDefinitionBuilderTest < Test::Unit::TestCase

      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with sensible defaults' do
        # Repository needs unit of work provider (initialized by default)
        # Repository needs event bus
        @builder.simple_event_bus

        # LockingRepository needs a locking manager (pessimistic by default)
        # EventSourcingRepository needs an event store
        @builder.factory :event_store do
          Object.new
        end

        # EventSourcingRepository needs an aggregate factory
        @builder.es_repository :account_repository do
          use_aggregate_type Object
        end

        repository = @container.resolve :account_repository

        event_bus = @container.resolve :event_bus
        event_store = @container.resolve :event_store
        unit_provider = @container.resolve :unit_provider

        assert_same event_bus, repository.event_bus
        assert_same event_store, repository.event_store
        assert_same unit_provider, repository.unit_provider

        assert_instance_of Repository::PessimisticLockManager, repository.lock_manager
      end

      should 'build with optional components' do
        @builder.simple_event_bus
        @builder.factory :event_store do
          Object.new
        end

        @builder.aggregate_snapshot_taker
        @builder.interval_snapshot_policy

        @builder.factory :conflict_resolver do
          EventSourcing::ConflictResolver.new
        end

        @builder.es_repository :account_repository do
          use_aggregate_type Object
        end

        repository = @container.resolve :account_repository

        conflict_resolver = @container.resolve :conflict_resolver
        snapshot_policy = @container.resolve :snapshot_policy
        snapshot_taker = @container.resolve :snapshot_taker

        assert_same conflict_resolver, repository.conflict_resolver
        assert_same snapshot_policy, repository.snapshot_policy
        assert_same snapshot_taker, repository.snapshot_taker
      end

    end
  end
end
