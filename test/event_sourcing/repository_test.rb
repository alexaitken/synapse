require 'test_helper'
require 'domain/fixtures'

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

      should 'raise an exception if an incompatible aggregate is added' do
        aggregate = Domain::Person.new 123, 'Polandball'

        assert_raise ArgumentError do
          @repository.add aggregate # Polandball can't into repository :(
        end
      end

      should 'load an aggregate from an event stream' do
        event = create_event(123, 0, StubCreatedEvent.new(123))

        mock(@event_store).read_events(@factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event
        end

        aggregate = @repository.load 123
      end

      should 'raise an exception if an unexpected aggregate version is loaded' do
        event = create_event(123, 1, StubCreatedEvent.new(123))

        mock(@event_store).read_events(@factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event
        end

        assert_raise Repository::ConflictingAggregateVersionError do
          aggregate = @repository.load 123, 0
        end
      end

      should 'raise an exception if an event stream could not be found for the aggregate id' do
        mock(@event_store).read_events(@factory.type_identifier, 123) do
          raise EventStore::StreamNotFoundError.new @factory.type_identifier, 123
        end

        assert_raise Repository::AggregateNotFoundError do
          @repository.load 123
        end
      end

      should 'raise an exception if the loaded aggregate has been marked for deletion' do
        event_a = create_event(123, 0, StubCreatedEvent.new(123))
        event_b = create_event(123, 1, StubDeletedEvent.new)

        mock(@event_store).read_events(@factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event_a, event_b
        end

        assert_raise AggregateDeletedError do
          aggregate = @repository.load 123
        end
      end

      should 'defer version checking to a conflict resolver if one is set' do
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
