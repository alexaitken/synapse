require 'spec_helper'

module Synapse
  module Configuration

    describe EventSourcingRepositoryDefinitionBuilder do
      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      it 'builds with sensible defaults' do
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

        repository.event_bus.should be(event_bus)
        repository.event_store.should be(event_store)
        repository.unit_provider.should be(unit_provider)

        repository.lock_manager.should be_a(Repository::PessimisticLockManager)
      end

      it 'builds with optional components' do
        @builder.simple_event_bus
        @builder.factory :event_store do
          Object.new
        end

        @builder.snapshot_taker
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

        repository.conflict_resolver.should be(conflict_resolver)
        repository.snapshot_policy.should be(snapshot_policy)
        repository.snapshot_taker.should be(snapshot_taker)
      end

      it 'builds a caching repository if cache is set' do
        @builder.simple_event_bus
        @builder.factory :event_store do
          Object.new
        end

        @builder.factory :cache do
          Object.new
        end

        @builder.es_repository :account_repository do
          use_aggregate_type Object
          use_cache :cache
        end

        repository = @container.resolve :account_repository

        cache = @container.resolve :cache

        repository.should be_a(EventSourcing::CachingEventSourcingRepository)
        repository.cache.should be(cache)
      end
    end

  end
end
