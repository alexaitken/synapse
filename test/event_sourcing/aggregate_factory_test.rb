require 'test_helper'

module Synapse
  module EventSourcing

    class GenericAggregateFactoryTest < Test::Unit::TestCase
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
        snapshot_event = Domain::DomainEventMessage.build do |m|
          m.payload = snapshot
        end

        aggregate = @factory.create_aggregate 123, snapshot_event

        assert aggregate.equal? snapshot
      end
    end

  end
end
