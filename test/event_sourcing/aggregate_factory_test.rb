require 'test_helper'

module Synapse
  module EventSourcing

    class GenericAggregateFactoryTest < Test::Unit::TestCase
      def test_create_aggregate
        factory = GenericAggregateFactory.new StubAggregate

        event = Domain::DomainEventMessage.new do |m|
          m.payload = StubCreatedEvent.new 123
        end

        snapshot = StubAggregate.new 123
        snapshot_event = Domain::DomainEventMessage.new do |m|
          m.payload = snapshot
        end

        aggregate_a = factory.create_aggregate(123, snapshot_event)
        aggregate_b = factory.create_aggregate(123, event)

        assert aggregate_a.equal? snapshot
        assert aggregate_b.is_a? StubAggregate
      end
    end

  end
end
