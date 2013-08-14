require 'spec_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe AggregateSnapshotTaker do
      let(:event_store) { Object.new }
      let(:aggregate_factory) { GenericAggregateFactory.new StubAggregate }

      subject {
        AggregateSnapshotTaker.new.tap { |t|
          t.event_store = event_store
          t.register_factory aggregate_factory
        }
      }

      it 'stores a snapshot by serializing the aggregate itself' do
        type_identifier = aggregate_factory.type_identifier
        id = SecureRandom.uuid

        events = Array.new
        events.push create_domain_event StubCreatedEvent.new(id), 0, id
        events.push create_domain_event StubChangedEvent.new, 1, id
        events.push create_domain_event StubChangedEvent.new, 2, id

        stream = Domain::SimpleDomainEventStream.new events

        mock(event_store).read_events(type_identifier, id) do
          stream
        end

        mock(event_store).append_snapshot_event(type_identifier, anything) do |_, snapshot|
          snapshot.aggregate_id.should == id
          snapshot.payload_type.should == StubAggregate
          snapshot.sequence_number.should == 2
        end

        subject.schedule_snapshot type_identifier, id
      end

      it 'does not store a snapshot if it replaces only one event' do
        type_identifier = aggregate_factory.type_identifier
        id = SecureRandom.uuid

        events = Array.new
        events.push create_domain_event StubCreatedEvent.new(id), 0, id

        stream = Domain::SimpleDomainEventStream.new events

        mock(event_store).read_events(type_identifier, id) do
          stream
        end

        subject.schedule_snapshot type_identifier, id
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
