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

        @repository = EventSourcingRepository.new @factory, @event_store
        @repository.unit_provider = @unit_provider
        @repository.lock_manager = Repository::LockManager.new # Dummy lock manager
      end

      def test_load
        event = create_event(123, 0, StubCreatedEvent.new(123))

        mock(@event_store).read(@factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event
        end

        aggregate = @repository.load 123
      end

      def test_load_not_found
        mock(@event_store).read(@factory.type_identifier, 123) do
          raise EventStore::StreamNotFoundError
        end

        assert_raise Repository::AggregateNotFoundError do
          @repository.load 123
        end
      end

      def test_load_deleted
        event_a = create_event(123, 0, StubCreatedEvent.new(123))
        event_b = create_event(123, 1, StubDeletedEvent.new)

        mock(@event_store).read(@factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event_a, event_b
        end

        assert_raise AggregateDeletedError do
          aggregate = @repository.load 123
        end
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
