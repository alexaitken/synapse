require 'spec_helper'

module Synapse
  module EventStore

    describe InMemoryEventStore do
      before do
        @event_store = InMemoryEventStore.new
      end

      it 'raises an exception if a stream could not be found' do
        expect {
          @event_store.read_events 'Person', 123
        }.to raise_error StreamNotFoundError
      end

      it 'supports appending and reading an event stream' do
        event_a = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }
        event_b = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }
        event_c = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }

        stream_a = Domain::SimpleDomainEventStream.new event_a, event_b
        stream_b = Domain::SimpleDomainEventStream.new event_c

        @event_store.append_events 'Person', stream_a
        @event_store.append_events 'Person', stream_b

        stream = @event_store.read_events 'Person', 123
        stream.to_a.should == [event_a, event_b, event_c]
      end

      it 'supports clearing all event streams' do
        event = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }
        stream = Domain::SimpleDomainEventStream.new event

        @event_store.append_events 'Person', stream
        @event_store.clear

        expect {
          @event_store.read_events 'Person', 123
        }.to raise_error StreamNotFoundError
      end
    end

  end
end
