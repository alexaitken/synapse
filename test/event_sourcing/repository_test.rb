require 'test_helper'

module Synapse
  module EventSourcing
    class EventSourcingRepositoryTest < Test::Unit::TestCase
      def setup
        @unit_provider = UnitOfWork::UnitOfWorkProvider.new
        @unit = UnitOfWork::UnitOfWork.new @unit_provider
        @unit.start
        @factory = GenericAggregateFactory.new StubAggregate
        @event_store = Object.new
        @lock_manager = Repository::NullLockManager.new

        @repository = EventSourcingRepository.new @factory, @event_store, @lock_manager
        @repository.event_bus = EventBus::SimpleEventBus.new
        @repository.unit_provider = @unit_provider
      end

      def test_load
        event = create_event(123, 0, StubCreatedEvent.new(123))

        mock(@event_store).read_events(@factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event
        end

        aggregate = @repository.load 123
      end

      def test_load_not_found
        mock(@event_store).read_events(@factory.type_identifier, 123) do
          raise EventStore::StreamNotFoundError.new @factory.type_identifier, 123
        end

        assert_raise Repository::AggregateNotFoundError do
          @repository.load 123
        end
      end

      def test_load_deleted
        event_a = create_event(123, 0, StubCreatedEvent.new(123))
        event_b = create_event(123, 1, StubDeletedEvent.new)

        mock(@event_store).read_events(@factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event_a, event_b
        end

        assert_raise AggregateDeletedError do
          aggregate = @repository.load 123
        end
      end

      def test_conflict_resolution
        @repository.conflict_resolver = ConflictResolver.new

        event_a = create_event(123, 0, StubCreatedEvent.new(123))
        event_b = create_event(123, 1, StubChangedEvent.new)

        mock(@event_store).read_events(@factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event_a, event_b
        end

        mock(@event_store).append_events(@factory.type_identifier, anything)

        aggregate = @repository.load 123, 0
        aggregate.change_something

        @unit.commit
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
