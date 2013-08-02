require 'spec_helper'

module Synapse
  module Repository

    describe LockingRepository do
      before do
        @event_bus = Object.new
        @lock_manager = Object.new
        @unit_provider = UnitOfWork::UnitOfWorkProvider.new

        @unit = UnitOfWork::UnitOfWork.new @unit_provider
        @unit.start

        @repository = TestRepository.new @lock_manager
        @repository.event_bus = @event_bus
        @repository.unit_provider = @unit_provider
      end

      it 'handles locking when an aggregate is added' do
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = TestAggregateRoot.new 123, nil

        @repository.add aggregate
        @unit.commit
      end

      it 'raises an exception if an incompatible aggregate is added' do
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = OpenStruct.new
        aggregate.id = 123

        expect {
          @repository.add aggregate
        }.to raise_error ArgumentError
      end

      it 'raises an exception if an aggregate is added that already has a version' do
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        aggregate = TestAggregateRoot.new 123, 0

        expect {
          @repository.add aggregate
        }.to raise_error ArgumentError
      end

      it 'raises an exception if a loaded aggregate has an unexpected version' do
        mock(@lock_manager).obtain_lock(123)
        mock(@lock_manager).release_lock(123)

        @repository.aggregate = TestAggregateRoot.new 123, 1

        expect {
          @repository.load 123, 0
        }.to raise_error ConflictingAggregateVersionError
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
