require 'spec_helper'
require 'domain/fixtures'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe EventSourcingRepository do
      before do
        @unit_provider = UnitOfWork::UnitOfWorkProvider.new
        @unit = UnitOfWork::UnitOfWork.new @unit_provider
        @unit.start
        @factory = GenericAggregateFactory.new StubAggregate
        @event_store = Object.new
        @lock_manager = Repository::NullLockManager.new

        @repository = EventSourcingRepository.new @factory, @event_store, @lock_manager
        @repository.event_bus = EventBus::SimpleEventBus.new
        @repository.unit_provider = @unit_provider

        @id = SecureRandom.uuid
      end

      it 'raises an exception if an incompatible aggregate is added' do
        aggregate = Domain::Person.new @id, 'Polandball'

        expect {
          @repository.add aggregate # Polandball can't into repository :(
        }.to raise_error ArgumentError
      end

      it 'loads an aggregate from an event stream' do
        event = create_event(@id, 0, StubCreatedEvent.new(@id))

        mock(@event_store).read_events(@factory.type_identifier, @id) do
          Domain::SimpleDomainEventStream.new event
        end

        aggregate = @repository.load @id
      end

      it 'raises an exception if an unexpected aggregate version is loaded' do
        event = create_event(@id, 1, StubCreatedEvent.new(@id))

        mock(@event_store).read_events(@factory.type_identifier, @id) do
          Domain::SimpleDomainEventStream.new event
        end

        expect {
          @repository.load @id, 0
        }.to raise_error Repository::ConflictingAggregateVersionError
      end

      it 'raises an exception if an event stream could not be found for the aggregate id' do
        mock(@event_store).read_events(@factory.type_identifier, @id) do
          raise EventStore::StreamNotFoundError.new @factory.type_identifier, @id
        end

        expect {
          @repository.load @id
        }.to raise_error Repository::AggregateNotFoundError
      end

      it 'raises an exception if the loaded aggregate has been marked for deletion' do
        event_a = create_event(@id, 0, StubCreatedEvent.new(@id))
        event_b = create_event(@id, 1, StubDeletedEvent.new)

        mock(@event_store).read_events(@factory.type_identifier, @id) do
          Domain::SimpleDomainEventStream.new event_a, event_b
        end

        expect {
          @repository.load @id
        }.to raise_error AggregateDeletedError
      end

      it 'raises an exception while saving if lock could not be validated' do
        event = create_event(@id, 0, StubCreatedEvent.new(@id))

        mock(@event_store).read_events(@factory.type_identifier, @id) do
          Domain::SimpleDomainEventStream.new event
        end

        aggregate = @repository.load @id

        mock(@lock_manager).validate_lock(aggregate) do
          false
        end

        expect {
          @unit.commit
        }.to raise_error Repository::ConcurrencyError
      end

      it 'defers version checking to a conflict resolver if one is set' do
        @repository.conflict_resolver = AcceptAllConflictResolver.new

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

      it 'registers a snapshot listener if a policy and taker are set' do
        @repository.snapshot_policy = IntervalSnapshotPolicy.new 30
        @repository.snapshot_taker = AggregateSnapshotTaker.new
        @repository.snapshot_taker.event_store = @event_store

        mock(@unit).register_listener(anything)
        mock(@unit).register_listener(is_a(SnapshotUnitOfWorkListener))

        @repository.add StubAggregate.new 123
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
