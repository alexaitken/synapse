require 'spec_helper'

module Synapse
  module Repository

    describe SimpleRepository do
      before do
        @unit_provider = UnitOfWork::UnitOfWorkProvider.new
        @unit_factory = UnitOfWork::UnitOfWorkFactory.new @unit_provider

        @lock_manager = NullLockManager.new

        @repository = SimpleRepository.new @lock_manager, TestMappedAggregate
        @repository.event_bus = EventBus::SimpleEventBus.new
        @repository.unit_provider = @unit_provider
      end

      it 'loads an aggregate using its finder' do
        unit = @unit_factory.create

        aggregate_id = SecureRandom.uuid
        aggregate = TestMappedAggregate.new aggregate_id

        mock(TestMappedAggregate).find(aggregate_id) do
          aggregate
        end

        loaded = @repository.load aggregate_id
        loaded.should be(aggregate)
      end

      it 'raises an exception if the aggregate could not be found' do
        aggregate_id = SecureRandom.uuid

        mock(TestMappedAggregate).find(aggregate_id)

        expect {
          @repository.load aggregate_id
        }.to raise_error(AggregateNotFoundError)
      end

      it 'raises an exception if the loaded aggregate has an unexpected version' do
        unit = @unit_factory.create

        aggregate_id = SecureRandom.uuid
        aggregate = TestMappedAggregate.new aggregate_id
        aggregate.version = 5

        mock(TestMappedAggregate).find(aggregate_id) do
          aggregate
        end

        expect {
          @repository.load aggregate_id, 4
        }.to raise_error(ConflictingAggregateVersionError)
      end

      it 'raises an exception while saving if lock could not be validated' do
        unit = @unit_factory.create

        aggregate_id = SecureRandom.uuid
        aggregate = TestMappedAggregate.new aggregate_id
        aggregate.version = 5

        mock(TestMappedAggregate).find(aggregate_id) do
          aggregate
        end

        @repository.load aggregate_id

        mock(@lock_manager).validate_lock(aggregate) do
          false
        end

        expect {
          unit.commit
        }.to raise_error(ConcurrencyError)
      end

      it 'deletes the aggregate if it has been marked for deletion' do
        unit = @unit_factory.create

        aggregate_id = SecureRandom.uuid
        aggregate = TestMappedAggregate.new aggregate_id
        aggregate.delete_this_thing

        @repository.add aggregate

        mock(aggregate).destroy

        unit.commit
      end

      it 'saves the aggregate upon commit' do
        unit = @unit_factory.create

        aggregate_id = SecureRandom.uuid
        aggregate = TestMappedAggregate.new aggregate_id

        @repository.add aggregate

        mock(aggregate).save
        mock.proxy(aggregate).mark_committed

        unit.commit
      end
    end

    class TestMappedAggregate
      include Domain::AggregateRoot

      attr_accessor :version

      def initialize(id)
        @id = id
      end

      def delete_this_thing
        mark_deleted
      end
    end

  end
end
