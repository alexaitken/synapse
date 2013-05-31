require 'test_helper'

module Synapse
  module Repository
    class SimpleRepositoryTest < Test::Unit::TestCase
      def setup
        @unit_provider = UnitOfWork::UnitOfWorkProvider.new
        @unit_factory = UnitOfWork::UnitOfWorkFactory.new @unit_provider

        @repository = SimpleRepository.new NullLockManager.new, TestMappedAggregate
        @repository.event_bus = EventBus::SimpleEventBus.new
        @repository.unit_provider = @unit_provider
      end

      def test_load
        unit = @unit_factory.create

        aggregate = TestMappedAggregate.new '5677b4f7'
        mock(TestMappedAggregate).find(aggregate.id) do
          aggregate
        end

        loaded = @repository.load aggregate.id

        assert_same loaded, aggregate
      end

      def test_load_not_found
        mock(TestMappedAggregate).find('5677b4f7')

        assert_raise AggregateNotFoundError do
          @repository.load '5677b4f7'
        end
      end

      def test_load_unexpected
        unit = @unit_factory.create

        aggregate = TestMappedAggregate.new '5677b4f7'
        aggregate.version = 5

        mock(TestMappedAggregate).find(aggregate.id) do
          aggregate
        end

        assert_raise ConflictingAggregateVersionError do
          @repository.load aggregate.id, 4
        end
      end

      def test_delete
        unit = @unit_factory.create

        aggregate = TestMappedAggregate.new '5677b4f7'
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
