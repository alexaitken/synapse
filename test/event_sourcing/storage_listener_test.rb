require 'test_helper'

module Synapse
  module EventSourcing

    class EventSourcedStorageListenerTest < Test::Unit::TestCase
      def test_store
        event_store = Object.new
        lock_manager = Object.new
        decorators = Array.new
        type_identifier = StubAggregate.to_s.demodulize
        aggregate = Object.new

        decorator = Object.new
        decorators.push decorator

        original_stream = Domain::DomainEventStream.new
        decorated_stream = Domain::DomainEventStream.new

        mock(aggregate).version
        mock(aggregate).uncommitted_events do
          original_stream
        end
        mock(aggregate).mark_committed

        mock(decorator).decorate_for_append(type_identifier, aggregate, original_stream) do
          decorated_stream
        end

        mock(event_store).append(type_identifier, decorated_stream)

        listener = EventSourcedStorageListener.new event_store, lock_manager, decorators, type_identifier
        listener.store aggregate
      end

      def test_store_locking
        event_store = Object.new
        lock_manager = Object.new
        decorators = Array.new
        type_identifier = StubAggregate.to_s.demodulize
        aggregate = Object.new

        mock(aggregate).version do
          123
        end

        mock(lock_manager).validate_lock(aggregate) do
          false
        end

        listener = EventSourcedStorageListener.new event_store, lock_manager, decorators, type_identifier

        assert_raise Repository::ConflictingModificationError do
          listener.store aggregate
        end
      end
    end

  end
end
