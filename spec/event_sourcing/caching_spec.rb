require 'spec_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe CachingEventSourcingRepository do
      before do
        # i herd u like dependencies
        @unit_provider = UnitOfWork::UnitOfWorkProvider.new
        @unit = UnitOfWork::UnitOfWork.new @unit_provider
        @unit.start
        @factory = GenericAggregateFactory.new StubAggregate
        @event_store = Object.new
        @lock_manager = Repository::NullLockManager.new
        @cache = Object.new

        @repository = CachingEventSourcingRepository.new @factory, @event_store, @lock_manager
        @repository.cache = @cache
        @repository.event_bus = EventBus::SimpleEventBus.new
        @repository.unit_provider = @unit_provider
      end

      it 'loads from cache before hitting the event store' do
        aggregate_id = SecureRandom.uuid
        aggregate = StubAggregate.new aggregate_id

        mock(@cache).fetch(aggregate_id) do
          aggregate
        end

        @repository.load(aggregate_id).should be(aggregate)
      end

      it 'raises an exception if the aggregate loaded from the cache is marked for deletion' do
        aggregate_id = SecureRandom.uuid
        aggregate = StubAggregate.new aggregate_id
        aggregate.delete_me

        mock(@cache).fetch(aggregate_id) do
          aggregate
        end

        expect {
          @repository.load aggregate_id
        }.to raise_error(AggregateDeletedError)
      end

      it 'loads from the event store if cache miss' do
        type_identifier = @factory.type_identifier
        aggregate_id = SecureRandom.uuid

        mock(@cache).fetch(aggregate_id)
        mock(@event_store).read_events(type_identifier, aggregate_id) do
          raise EventStore::StreamNotFoundError.new(type_identifier, aggregate_id)
        end

        expect {
          @repository.load aggregate_id
        }.to raise_error(Repository::AggregateNotFoundError)
      end

      it 'clears the cache if the unit of work is rolled back' do
        aggregate_id = SecureRandom.uuid
        aggregate = StubAggregate.new aggregate_id

        mock(@cache).fetch(aggregate_id) do
          aggregate
        end

        mock(@cache).delete(aggregate_id)

        @repository.load aggregate_id
        @unit.rollback
      end

      it 'deletes aggregate from cache when aggregate is deleted' do
        type_identifier = @factory.type_identifier
        aggregate_id = SecureRandom.uuid
        aggregate = StubAggregate.new aggregate_id

        mock(@cache).fetch(aggregate_id).ordered do
          aggregate
        end

        mock(@event_store).append_events(type_identifier, anything).ordered

        mock(@cache).write(aggregate_id, aggregate).ordered

        loaded_aggregate = @repository.load aggregate_id
        loaded_aggregate.delete_me

        @unit.commit
      end

      it 'deletes aggregate from cache when commit goes wrong' do
        type_identifier = @factory.type_identifier
        aggregate_id = SecureRandom.uuid
        aggregate = StubAggregate.new aggregate_id

        mock(@cache).fetch(aggregate_id).ordered do
          aggregate
        end

        mock(@event_store).append_events(type_identifier, anything).ordered do
          raise
        end

        mock(@cache).delete(aggregate_id).ordered

        @repository.load aggregate_id

        expect {
          @unit.commit
        }.to raise_error(RuntimeError)
      end
    end

  end
end
