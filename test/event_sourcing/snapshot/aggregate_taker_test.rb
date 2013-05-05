require 'test_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    class AggregateSnapshotTakerTest < Test::Unit::TestCase
      def test_schedule_snapshot
        event_store = Object.new
        aggregate_factory = GenericAggregateFactory.new StubAggregate

        type_identifier = aggregate_factory.type_identifier
        id = 123

        event = Domain::DomainEventMessage.build do |builder|
          builder.payload = StubCreatedEvent.new id
          builder.sequence_number = 0
          builder.aggregate_id = id
        end
        stream = Domain::SimpleDomainEventStream.new event

        mock(event_store).read_events(type_identifier, id) do
          stream
        end

        mock(event_store).append_snapshot_event(type_identifier, anything) do |_, snapshot|
          assert_equal StubAggregate, snapshot.payload_type
          assert_equal 0, snapshot.sequence_number
          assert_equal id, snapshot.aggregate_id
        end

        snapshot_taker = AggregateSnapshotTaker.new event_store
        snapshot_taker.register_factory aggregate_factory
        snapshot_taker.schedule_snapshot type_identifier, id
      end
    end

  end
end
