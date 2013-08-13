require 'spec_helper'
require 'event_sourcing/fixtures'

module Synapse
  module Persistence

    class InMemoryLockingRepository < LockingRepository
      attr_reader :save_count

      def initialize(lock_manager)
        super

        @aggregates = Hash.new
        @save_count = 0
      end

      def reset_save_count
        @save_count = 0
      end

      protected

      def perform_load(aggregate_id, expected_version)
        @aggregates.fetch aggregate_id
      rescue KeyError
        raise AggregateNotFoundError
      end

      def save_aggregate_with_lock(aggregate)
        @aggregates.put aggregate.id, aggregate
        @save_count += 1
      end

      def delete_aggregate_with_lock(aggregate)
        @aggregates.delete aggregate.id
        @save_count += 1
      end

      def aggregate_type
        StubAggregate
      end
    end

    StubAggregate = EventSourcing::StubAggregate

  end
end
