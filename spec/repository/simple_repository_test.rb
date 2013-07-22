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

      it 'load an aggregate using its finder' do
        unit = @unit_factory.create

        aggregate_id = SecureRandom.uuid
        aggregate = TestMappedAggregate.new aggregate_id

        mock(TestMappedAggregate).find(aggregate_id) do
          aggregate
        end

        loaded = @repository.load aggregate_id

        assert_same loaded, aggregate
      end

      it 'raise an exception if the aggregate could not be found' do
        aggregate_id = SecureRandom.uuid

        mock(TestMappedAggregate).find(aggregate_id)

        assert_raise AggregateNotFoundError do
          @repository.load aggregate_id
        end
      end

      it 'raise an exception if the loaded aggregate has an unexpected version' do
        unit = @unit_factory.create

        aggregate_id = SecureRandom.uuid
        aggregate = TestMappedAggregate.new aggregate_id
        aggregate.version = 5

        mock(TestMappedAggregate).find(aggregate_id) do
          aggregate
        end

        assert_raise ConflictingAggregateVersionError do
          @repository.load aggregate_id, 4
        end
      end

      it 'raise an exception while saving if lock could not be validated' do
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

        assert_raise ConcurrencyError do
          unit.commit
        end
      end

      it 'delete the aggregate if it has been marked for deletion' do
        unit = @unit_factory.create

        aggregate_id = SecureRandom.uuid
        aggregate = TestMappedAggregate.new aggregate_id
        aggregate.delete_this_thing

        @repository.add aggregate

        mock(aggregate).destroy

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
