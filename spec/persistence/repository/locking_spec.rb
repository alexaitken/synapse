require 'spec_helper'
require 'ostruct'
require 'persistence/repository/fixtures'
require 'unit_of_work/fixtures'

module Synapse
  module Persistence

    describe LockingRepository do
      after do
        CurrentUnit.rollback_all
      end

      let(:lock_manager) { Object.new }
      let(:event_bus) { Object.new }

      subject {
        InMemoryLockingRepository.new(lock_manager).tap { |r|
          r.event_bus = event_bus
        }
      }

      it 'refuses aggregates to add that are not the correct type' do
        aggregate = OpenStruct.new id: 123

        mock(lock_manager).obtain_lock(aggregate.id)
        mock(lock_manager).release_lock(aggregate.id)

        DefaultUnit.start

        expect {
          subject.add aggregate
        }.to raise_error ArgumentError
      end

      it 'refuses aggregates to add that not new' do
        aggregate = StubAggregate.new
        aggregate.do_something
        aggregate.mark_committed

        mock(lock_manager).obtain_lock(aggregate.id)
        mock(lock_manager).release_lock(aggregate.id)

        DefaultUnit.start

        expect {
          subject.add aggregate
        }.to raise_error ArgumentError
      end

      it 'stores new aggregates' do
        DefaultUnit.start

        aggregate = StubAggregate.new
        aggregate.do_something

        mock(lock_manager).obtain_lock(aggregate.id)

        subject.add aggregate

        mock(event_bus).publish(is_a(DomainEventMessage))
        mock(lock_manager).release_lock(aggregate.id)

        CurrentUnit.commit
      end

      it 'loads and stores aggregates' do
        DefaultUnit.start

        aggregate = StubAggregate.new
        aggregate.do_something

        mock(lock_manager).obtain_lock(aggregate.id)
        subject.add aggregate

        mock(event_bus).publish(is_a(DomainEventMessage))
        mock(lock_manager).release_lock(aggregate.id)

        CurrentUnit.commit

        DefaultUnit.start

        mock(lock_manager).obtain_lock(aggregate.id)
        loaded_aggregate = subject.load aggregate.id, 0

        loaded_aggregate.do_something

        mock(event_bus).publish(is_a(DomainEventMessage))
        mock(lock_manager).validate_lock(aggregate).returns(true)
        mock(lock_manager).release_lock(aggregate.id)

        CurrentUnit.commit
      end

      it 'releases its lock if an error occurs during commit' do
        DefaultUnit.start

        aggregate = StubAggregate.new
        aggregate.do_something

        mock(lock_manager).obtain_lock(aggregate.id)
        subject.add aggregate

        mock(event_bus).publish(is_a(DomainEventMessage))
        mock(lock_manager).release_lock(aggregate.id)

        CurrentUnit.commit

        DefaultUnit.start

        mock(lock_manager).obtain_lock(aggregate.id)
        loaded_aggregate = subject.load aggregate.id, 0

        current_unit = CurrentUnit.get

        listener = TestUnitListener.new
        mock(listener).on_prepare_commit(current_unit, anything, anything) do
          raise MockError
        end

        current_unit.register_listener listener

        mock(lock_manager).release_lock(aggregate.id)

        expect {
          CurrentUnit.commit
        }.to raise_error MockError
      end

      it 'releases its lock if an error occurs while loading' do
        DefaultUnit.start

        id = SecureRandom.uuid

        mock(lock_manager).obtain_lock(id)
        mock(lock_manager).release_lock(id)

        expect {
          subject.load id
        }.to raise_error AggregateNotFoundError
      end

      it 'validates locks before saving an aggregate' do

      end

      CurrentUnit = UnitOfWork::CurrentUnit
      DefaultUnit = UnitOfWork::DefaultUnit
      DomainEventMessage = Domain::DomainEventMessage
      TestUnitListener = UnitOfWork::TestUnitListener
      MockError = UnitOfWork::MockError
    end

  end
end
