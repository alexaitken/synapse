require 'test_helper'

module Synapse
  module Repository
    class LockingRepositoryTest < Test::Unit::TestCase
      def setup
        @event_bus = Object.new
        @lock_manager = Object.new
        @storage_listener = Object.new
        @unit_provider = UnitOfWork::UnitOfWorkProvider.new

        @unit = UnitOfWork::UnitOfWork.new @unit_provider
        @unit.start

        # I herd you like dependencies
        @repository = TestRepository.new @lock_manager
        @repository.event_bus = @event_bus
        @repository.storage_listener = @storage_listener
        @repository.unit_provider = @unit_provider
      end

      def test_add
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = TestAggregateRoot.new 123, nil

        mock(@storage_listener).store(aggregate)

        @repository.add aggregate
        @unit.commit
      end

      def test_add_incompatible_aggregate
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = OpenStruct.new
        aggregate.id = 123

        assert_raises ArgumentError do
          @repository.add aggregate
        end
      end

      def test_add_versioned
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = TestAggregateRoot.new 123, 0

        assert_raises ArgumentError do
          @repository.add aggregate
        end
      end

      def test_load_version_ahead
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        @repository.aggregate = TestAggregateRoot.new 123, 1

        assert_raises ConflictingAggregateVersionError do
          @repository.load 123, 0
        end
      end
    end

    class TestAggregateRoot
      include Domain::AggregateRoot

      def initialize(id, version)
        @id, @version = id, version
      end
    end

    class TestRepository < LockingRepository
      attr_accessor :aggregate, :storage_listener

    protected

      def perform_load(aggregate_id, expected_version)
        unless @aggregate
          raise AggregateNotFoundError
        end

        assert_version_expected @aggregate, expected_version

        @aggregate
      end

      def aggregate_type
        TestAggregateRoot
      end

      def storage_listener
        @storage_listener
      end
    end
  end
end
