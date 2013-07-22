require 'test_helper'

module Synapse
  module EventStore
    describe InMemoryEventStore do

      def setup
        @event_store = InMemoryEventStore.new
      end

      should 'raise an exception if a stream could not be found' do
        assert_raise StreamNotFoundError do
          @event_store.read_events 'Person', 123
        end
      end

      should 'support appending and reading an event stream' do
        event_a = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }
        event_b = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }
        event_c = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }

        stream_a = Domain::SimpleDomainEventStream.new event_a, event_b
        stream_b = Domain::SimpleDomainEventStream.new event_c

        @event_store.append_events 'Person', stream_a
        @event_store.append_events 'Person', stream_b

        stream = @event_store.read_events 'Person', 123

        assert_equal [event_a, event_b, event_c], stream.to_a
      end

      should 'be able to be cleared of all streams' do
        event = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }
        stream = Domain::SimpleDomainEventStream.new event

        @event_store.append_events 'Person', stream
        @event_store.clear

        assert_raise StreamNotFoundError do
          @event_store.read_events 'Person', 123
        end
      end

    end
  end
end
