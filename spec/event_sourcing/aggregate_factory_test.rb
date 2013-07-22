require 'test_helper'

module Synapse
  module EventSourcing

    describe GenericAggregateFactory do
      def setup
        @factory = GenericAggregateFactory.new StubAggregate
      end

      should 'create an aggregate from a normal event' do
        event = Domain::DomainEventMessage.build do |m|
          m.payload = StubCreatedEvent.new 123
        end

        aggregate = @factory.create_aggregate 123, event

        assert aggregate.is_a? StubAggregate
      end

      should 'use an aggregate snapshot if available' do
        snapshot = StubAggregate.new 123
        snapshot.change_something
        snapshot.mark_committed

        snapshot_event = Domain::DomainEventMessage.build do |m|
          m.payload = snapshot
        end

        aggregate = @factory.create_aggregate 123, snapshot_event

        assert_same snapshot, aggregate
        assert_equal snapshot.version, aggregate.initial_version
      end
    end

  end
end
