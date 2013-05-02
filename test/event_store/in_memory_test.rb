require 'test_helper'

module Synapse
  module EventStore
    class InMemoryEventStoreTest < Test::Unit::TestCase

      def setup
        @event_store = InMemoryEventStore.new
      end

      def test_empty_stream
        assert_raise StreamNotFoundError do
          @event_store.read_events 'Person', 123
        end
      end

      def test_append_and_read
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

      def test_read_with_snapshot
        event_a = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }
        event_b = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }

        stream = Domain::SimpleDomainEventStream.new event_a, event_b

        snapshot_event = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }

        @event_store.append_events 'Person', stream
        @event_store.append_snapshot_event 'Person', snapshot_event

        stream = @event_store.read_events 'Person', 123

        assert_equal [snapshot_event], stream.to_a
      end

      def test_clear
        snapshot_event = Domain::DomainEventMessage.build { |e| e.aggregate_id = 123 }
        @event_store.append_snapshot_event 'Person', snapshot_event
        @event_store.clear

        assert_raise StreamNotFoundError do
          @event_store.read_events 'Person', 123
        end
      end

    end
  end
end
