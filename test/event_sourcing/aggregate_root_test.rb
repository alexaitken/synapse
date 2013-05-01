require 'test_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    class AggregateRootTest < Test::Unit::TestCase
      def test_apply
        stub = StubAggregate.new 123
        stub.change_something
        stub.change_something

        assert_equal 123, stub.id
        assert_equal 3, stub.uncommitted_event_count

        assert_nil stub.version

        stub.mark_committed

        assert_equal 2, stub.version
      end

      def test_new_from_stream
        events = Array.new
        events.push create_event(123, 0, StubCreatedEvent.new(123))
        events.push create_event(123, 1, StubChangedEvent.new)
        events.push create_event(123, 2, StubChangedEvent.new)

        stream = Domain::SimpleDomainEventStream.new events

        aggregate = StubAggregate.new_from_stream stream

        assert_equal 123, aggregate.id
        assert_equal 2, aggregate.version
      end

      def test_initialize_fails_after_initialization
        aggregate = StubAggregate.new 123

        assert_raise RuntimeError do
          aggregate.initialize_from_stream Domain::SimpleDomainEventStream.new
        end
      end

      def test_child_entities
        stub_entity_a = StubEntity.new
        stub_entity_b = StubEntity.new

        aggregate = StubAggregate.new 123
        aggregate.stub_entity = stub_entity_a
        aggregate.change_something

        stub_entity_a.change_something

        aggregate.stub_entities << stub_entity_b

        aggregate.change_something

        assert_equal 4, aggregate.event_count
        assert_equal 3, stub_entity_a.event_count
        assert_equal 1, stub_entity_b.event_count
      end

    private

      def create_event(aggregate_id, seq, payload)
        Domain::DomainEventMessage.new do |m|
          m.aggregate_id = aggregate_id
          m.sequence_number = seq
          m.payload = payload
        end
      end
    end

  end
end