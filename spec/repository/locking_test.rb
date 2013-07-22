require 'test_helper'

module Synapse
  module Repository
    class LockingRepositoryTest < Test::Unit::TestCase
      def setup
        @event_bus = Object.new
        @lock_manager = Object.new
        @unit_provider = UnitOfWork::UnitOfWorkProvider.new

        @unit = UnitOfWork::UnitOfWork.new @unit_provider
        @unit.start

        @repository = TestRepository.new @lock_manager
        @repository.event_bus = @event_bus
        @repository.unit_provider = @unit_provider
      end

      should 'handling locking when an aggregate is added' do
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = TestAggregateRoot.new 123, nil

        @repository.add aggregate
        @unit.commit
      end

      should 'raise an exception if an incompatible aggregate is added' do
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = OpenStruct.new
        aggregate.id = 123

        assert_raises ArgumentError do
          @repository.add aggregate
        end
      end

      should 'raise an exception if an aggregate is added that already has a version' do
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = TestAggregateRoot.new 123, 0

        assert_raises ArgumentError do
          @repository.add aggregate
        end
      end

      should 'raise an exception if a loaded aggregate has an unexpected version' do
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
      attr_accessor :aggregate

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

      def save_aggregate(aggregate); end
      def delete_aggregate(aggregate); end
    end
  end
end
