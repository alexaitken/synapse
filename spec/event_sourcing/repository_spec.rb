require 'spec_helper'
require 'domain/fixtures'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe EventSourcingRepository do
      let(:id) { SecureRandom.uuid }
      let(:aggregate_factory) { GenericAggregateFactory.new StubAggregate }
      let(:event_bus) { Object.new }
      let(:event_store) { Object.new }
      let(:lock_manager) { Persistence::NullLockManager.new }
      let(:unit) { UnitOfWork::DefaultUnit.new }

      subject {
        EventSourcingRepository.new(aggregate_factory, event_store, lock_manager).tap { |r|
          r.event_bus = event_bus
        }
      }

      before {
        unit.start
      }

      it 'raises an exception if an incompatible aggregate is added' do
        aggregate = Domain::Person.new id, 'Polandball'

        expect {
          subject.add aggregate # Polandball can't into repository :(
        }.to raise_error ArgumentError
      end

      it 'loads an aggregate from an event stream' do
        event = create_event(id, 0, StubCreatedEvent.new(id))

        mock(event_store).read_events(aggregate_factory.type_identifier, id) do
          Domain::SimpleDomainEventStream.new event
        end

        aggregate = subject.load id
      end

      it 'raises an exception if an unexpected aggregate version is loaded' do
        event = create_event(id, 1, StubCreatedEvent.new(id))

        mock(event_store).read_events(aggregate_factory.type_identifier, id) do
          Domain::SimpleDomainEventStream.new event
        end

        expect {
          subject.load id, 0
        }.to raise_error Persistence::ConflictingAggregateVersionError
      end

      it 'raises an exception if an event stream could not be found for the aggregate id' do
        mock(event_store).read_events(aggregate_factory.type_identifier, id) do
          raise EventStore::StreamNotFoundError.new
        end

        expect {
          subject.load id
        }.to raise_error Persistence::AggregateNotFoundError
      end

      it 'raises an exception if the loaded aggregate has been marked for deletion' do
        event_a = create_event(id, 0, StubCreatedEvent.new(id))
        event_b = create_event(id, 1, StubDeletedEvent.new)

        mock(event_store).read_events(aggregate_factory.type_identifier, id) do
          Domain::SimpleDomainEventStream.new event_a, event_b
        end

        expect {
          subject.load id
        }.to raise_error AggregateDeletedError
      end

      it 'raises an exception while saving if lock could not be validated' do
        event = create_event(id, 0, StubCreatedEvent.new(id))

        mock(event_store).read_events(aggregate_factory.type_identifier, id) do
          Domain::SimpleDomainEventStream.new event
        end

        aggregate = subject.load id

        mock(lock_manager).validate_lock(aggregate) do
          false
        end

        expect {
          unit.commit
        }.to raise_error Persistence::ConcurrencyError
      end

      it 'defers version checking to a conflict resolver if one is set' do
        subject.conflict_resolver = AcceptAllConflictResolver.new

        event_a = create_event(123, 0, StubCreatedEvent.new(123))
        event_b = create_event(123, 1, StubChangedEvent.new)

        mock(event_store).read_events(aggregate_factory.type_identifier, 123) do
          Domain::SimpleDomainEventStream.new event_a, event_b
        end

        mock(event_store).append_events(aggregate_factory.type_identifier, anything)

        aggregate = subject.load 123, 0
        aggregate.do_something

        unit.commit
      end

      it 'registers a snapshot listener if a policy and taker are set' do
        subject.snapshot_policy = IntervalSnapshotPolicy.new 30
        subject.snapshot_taker = AggregateSnapshotTaker.new
        subject.snapshot_taker.event_store = event_store

        mock(unit).register_listener(anything)
        mock(unit).register_listener(is_a(SnapshotUnitListener))

        subject.add StubAggregate.new 123
      end

    private

      def create_event(aggregate_id, seq, payload)
        Domain.build_message do |m|
          m.aggregate_id = aggregate_id
          m.sequence_number = seq
          m.payload = payload
        end
      end
    end

  end
end
