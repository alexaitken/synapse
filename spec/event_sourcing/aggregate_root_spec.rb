require 'spec_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe AggregateRoot do
      it 'tracks published events' do
        id = SecureRandom.uuid

        stub = StubAggregate.new id
        stub.do_something
        stub.do_something

        stub.id.should == id
        stub.uncommitted_event_count.should == 3
        stub.version.should be_nil

        stub.mark_committed

        stub.version.should == 2
        stub.uncommitted_event_count.should == 0
      end

      it 'supports initializing state from an event stream' do
        id = SecureRandom.uuid

        events = Array.new
        events.push create_event(id, 0, StubCreatedEvent.new(id))
        events.push create_event(id, 1, StubChangedEvent.new)
        events.push create_event(id, 2, StubChangedEvent.new)

        stream = Domain::SimpleDomainEventStream.new events

        aggregate = StubAggregate.new_from_stream stream

        aggregate.id.should == id
        aggregate.version == 2
        aggregate.initial_version == 0
      end

      it 'raises an exception if initialization is attempted when the aggregate has state' do
        aggregate = StubAggregate.new 123

        expect {
          aggregate.initialize_from_stream Domain::SimpleDomainEventStream.new
        }.to raise_error InvalidStateError
      end

      it 'notifies child entities of aggregate events' do
        stub_entity_a = StubEntity.new
        stub_entity_b = StubEntity.new

        aggregate = StubAggregate.new 123
        aggregate.stub_entity = stub_entity_a
        aggregate.do_something

        stub_entity_a.do_something

        aggregate.stub_entities.push stub_entity_b

        aggregate.do_something

        aggregate.event_count.should == 4
        stub_entity_a.event_count.should == 3
        stub_entity_b.event_count.should == 1
      end

    private

      def create_event(aggregate_id, seq, payload)
        Domain::DomainEventMessage.build do |m|
          m.aggregate_id = aggregate_id
          m.sequence_number = seq
          m.payload = payload
        end
      end
    end

  end
end

