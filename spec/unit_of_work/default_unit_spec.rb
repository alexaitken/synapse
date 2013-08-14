require 'spec_helper'
require 'unit_of_work/fixtures'

module Synapse
  module UnitOfWork

    describe DefaultUnit do
      before do
        CurrentUnit.rollback_all
      end

      after do
        if CurrentUnit.active?
          fail 'Unit of work was not properly cleared'
        end
      end

      ## State validation

      it 'raises an exception if start attempted when already active' do
        subject.start

        expect {
          subject.start
        }.to raise_error InvalidStateError

        subject.rollback
      end

      it 'raises an exception if commit attempted when not active' do
        expect {
          subject.commit
        }.to raise_error InvalidStateError
      end

      ## Transactional lifecycle

      it 'supports commit with a transaction manager' do
        listener = TestUnitListener.new
        txm = Object.new
        tx = Object.new

        mock(txm).start.returns(tx)

        unit = DefaultUnit.start txm
        unit.register_listener listener

        mock(listener).on_prepare_commit(unit, anything, anything).ordered
        mock(listener).on_prepare_transaction_commit(unit, tx).ordered
        mock(txm).commit(tx).ordered
        mock(listener).after_commit(unit)
        mock(listener).on_cleanup(unit)

        unit.commit
      end

      it 'supports rollback with a transaction manager' do
        listener = TestUnitListener.new
        txm = Object.new
        tx = Object.new

        mock(txm).start.returns(tx)

        unit = DefaultUnit.start txm
        unit.register_listener listener

        mock(txm).rollback(tx).ordered
        mock(listener).on_rollback(unit, anything).ordered
        mock(listener).on_cleanup(unit).ordered

        unit.rollback
      end

      ## Listeners

      it 'rolls back if errors occur while notifying listeners of on_prepare_commit' do
        listener = Object.new

        mock(listener).on_prepare_commit(subject, anything, anything) do
          raise MockError
        end
        mock(listener).on_rollback(subject, is_a(MockError)).ordered
        mock(listener).on_cleanup(subject).ordered

        subject.register_listener listener
        subject.start

        expect {
          subject.commit
        }.to raise_error MockError
      end

      ## Nesting

      it 'registers a commit listener when nesting' do
        outer_unit = Object.new
        CurrentUnit.set outer_unit

        mock(outer_unit).register_listener(is_a(OuterCommitListener))

        inner_unit = DefaultUnit.start
        inner_unit.rollback

        CurrentUnit.clear outer_unit
      end

      it 'delays commit until the outer unit is committed' do
        outer_unit = DefaultUnit.start
        inner_unit = DefaultUnit.start

        listener = TestUnitListener.new
        stub(listener).after_commit(inner_unit)

        inner_unit.register_listener listener
        inner_unit.commit

        expect(listener).to_not have_received.after_commit(inner_unit)

        outer_unit.commit

        expect(listener).to have_received.after_commit(inner_unit)
      end

      it 'rolls back if the outer unit is rolled back' do
        outer_unit = DefaultUnit.start
        inner_unit = DefaultUnit.start

        rolled_back = false
        listener = TestUnitListener.new
        stub(listener).on_rollback(inner_unit, anything)

        inner_unit.register_listener listener
        inner_unit.commit

        outer_unit.rollback

        expect(listener).to have_received.on_rollback(inner_unit, anything)
      end

      it 'delays cleanup from commit until outer unit is cleaned up from commit' do
        outer_unit = DefaultUnit.start
        inner_unit = DefaultUnit.start

        outer_listener = Object.new
        inner_listener = Object.new

        outer_unit.register_listener outer_listener
        inner_unit.register_listener inner_listener

        mock(inner_listener).on_prepare_commit(inner_unit, anything, anything).ordered

        inner_unit.commit

        mock(outer_listener).on_prepare_commit(outer_unit, anything, anything).ordered
        mock(inner_listener).after_commit(inner_unit).ordered
        mock(outer_listener).after_commit(outer_unit).ordered
        mock(inner_listener).on_cleanup(inner_unit).ordered
        mock(outer_listener).on_cleanup(outer_unit).ordered

        outer_unit.commit
      end

      it 'delays cleanup from rollback until outer unit is cleaned up from commit' do
        outer_unit = DefaultUnit.start
        inner_unit = DefaultUnit.start

        outer_listener = Object.new
        inner_listener = Object.new

        outer_unit.register_listener outer_listener
        inner_unit.register_listener inner_listener

        mock(inner_listener).on_rollback(inner_unit, anything).ordered

        inner_unit.rollback

        mock(outer_listener).on_prepare_commit(outer_unit, anything, anything).ordered
        mock(outer_listener).after_commit(outer_unit).ordered
        mock(inner_listener).on_cleanup(inner_unit).ordered
        mock(outer_listener).on_cleanup(outer_unit).ordered

        outer_unit.commit
      end

      it 'delays cleanup from commit until outer unit is cleaned up from rollback' do
        outer_unit = DefaultUnit.start
        inner_unit = DefaultUnit.start

        outer_listener = Object.new
        inner_listener = Object.new

        outer_unit.register_listener outer_listener
        inner_unit.register_listener inner_listener

        mock(inner_listener).on_prepare_commit(inner_unit, anything, anything).ordered

        inner_unit.commit

        mock(inner_listener).on_rollback(inner_unit, anything).ordered
        mock(outer_listener).on_rollback(outer_unit, anything).ordered
        mock(inner_listener).on_cleanup(inner_unit).ordered
        mock(outer_listener).on_cleanup(outer_unit).ordered

        outer_unit.rollback
      end

      it 'cascades rollback from outer unit to nested units' do
        outer_unit = StubOuterUnit.start
        middle_unit = DefaultUnit.start
        inner_unit = DefaultUnit.start

        middle_listener = TestUnitListener.new
        inner_listener = TestUnitListener.new

        middle_unit.register_listener middle_listener
        inner_unit.register_listener inner_listener

        inner_unit.commit
        middle_unit.commit

        mock(inner_listener).on_rollback(inner_unit, anything).ordered
        mock(middle_listener).on_rollback(middle_unit, anything).ordered

        outer_unit.rollback
      end

      it 'cascades rollback from inner unit to nested units' do
        event = Event.build_message
        event_bus = Object.new

        outer_unit = StubOuterUnit.start
        middle_unit = DefaultUnit.start
        inner_unit = DefaultUnit.start

        middle_listener = TestUnitListener.new
        inner_listener = TestUnitListener.new

        middle_unit.register_listener middle_listener
        inner_unit.register_listener inner_listener

        mock(event_bus).publish(event) do
          raise MockError
        end
        middle_unit.publish_event event, event_bus

        mock(inner_listener).on_rollback(inner_unit, anything).ordered
        mock(middle_listener).on_rollback(middle_unit, anything).ordered

        inner_unit.commit
        middle_unit.commit

        expect {
          outer_unit.commit
        }.to raise_error MockError
      end

      ## Aggregate registration

      it 'uses an identity map for aggregate registration' do
        id = SecureRandom.uuid
        aggregate_a = StubAggregate.new id
        aggregate_b = StubAggregate.new id

        event_bus = Object.new

        subject.start
        subject.register_aggregate(aggregate_a, event_bus, &nil).should be(aggregate_a)
        subject.register_aggregate(aggregate_b, event_bus, &nil).should be(aggregate_a)

        subject.rollback
      end

      it 'uses listeners to filter an aggregate event' do
        aggregate = StubAggregate.new 123
        event_bus = Object.new

        event_in = Domain.build_message
        event_out = Domain.build_message

        listener = TestUnitListener.new
        mock(listener).on_event_registered(subject, event_in).returns(event_out)

        subject.register_listener listener
        subject.register_aggregate aggregate, event_bus, &nil

        registration_listener = aggregate.listeners.first
        registration_listener.call(event_in).should be(event_out)
      end

      # Event publication

      it 'publishes events published by a listener' do
        event_bus = Object.new
        event_a = Event.build_message
        event_b = Event.build_message

        mock(event_bus).publish(event_a) do
          subject.publish_event event_b, event_bus
        end
        mock(event_bus).publish(event_b)

        subject.start
        subject.publish_event event_a, event_bus
        subject.commit
      end

      it 'defers publication of aggregate events until commit' do
        aggregate = StubAggregate.new 123
        event_bus = Object.new

        event = Domain.build_message

        subject.start
        subject.register_aggregate aggregate, event_bus do
          # don't do anything here
        end

        registration_listener = aggregate.listeners.first
        registration_listener.call event

        mock(event_bus).publish(event)

        subject.commit
      end

      it 'defers publication of registered events until commit' do
        event_in = Event.build_message
        event_out = Event.build_message

        event_bus = Object.new

        listener = TestUnitListener.new
        mock(listener).on_event_registered(subject, event_in).returns(event_out)

        subject.register_listener listener
        subject.start

        subject.publish_event event_in, event_bus

        mock(event_bus).publish(event_out)

        subject.commit
      end
    end

  end
end
