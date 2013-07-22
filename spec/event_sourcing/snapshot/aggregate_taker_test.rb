require 'test_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe AggregateSnapshotTaker do
      def setup
        @event_store = Object.new
        @aggregate_factory = GenericAggregateFactory.new StubAggregate

        @snapshot_taker = AggregateSnapshotTaker.new
        @snapshot_taker.event_store = @event_store
        @snapshot_taker.register_factory @aggregate_factory
      end

      should 'store a snapshot by serializing the aggregate itself' do
        type_identifier = @aggregate_factory.type_identifier
        id = SecureRandom.uuid

        events = Array.new
        events.push create_domain_event StubCreatedEvent.new(id), 0, id
        events.push create_domain_event StubChangedEvent.new, 1, id
        events.push create_domain_event StubChangedEvent.new, 2, id

        stream = Domain::SimpleDomainEventStream.new events

        mock(@event_store).read_events(type_identifier, id) do
          stream
        end

        mock(@event_store).append_snapshot_event(type_identifier, anything) do |_, snapshot|
          assert_equal StubAggregate, snapshot.payload_type
          assert_equal 2, snapshot.sequence_number
          assert_equal id, snapshot.aggregate_id
        end

        @snapshot_taker.schedule_snapshot type_identifier, id
      end

      should 'not store a snapshot if it replaces only one event' do
        type_identifier = @aggregate_factory.type_identifier
        id = SecureRandom.uuid

        events = Array.new
        events.push create_domain_event StubCreatedEvent.new(id), 0, id

        stream = Domain::SimpleDomainEventStream.new events

        mock(@event_store).read_events(type_identifier, id) do
          stream
        end

        @snapshot_taker.schedule_snapshot type_identifier, id
      end

    private

      def create_domain_event(payload, sequence_number, aggregate_id)
        Domain::DomainEventMessage.build do |builder|
          builder.payload = payload
          builder.sequence_number = sequence_number
          builder.aggregate_id = aggregate_id
        end
      end
    end

  end
end
