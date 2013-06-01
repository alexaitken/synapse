require 'test_helper'

module Synapse
  module UnitOfWork
    class UnitOfWorkTest < Test::Unit::TestCase
      def setup
        @provider = UnitOfWorkProvider.new
        @uow = UnitOfWork.new @provider
      end

      def teardown
        if @provider.started?
          raise 'Unit of work was not properly cleared from the provider'
        end
      end

      should 'raise an exception if the unit is started twice' do
        @uow.start

        assert_raises RuntimeError do
          @uow.start
        end

        @uow.rollback
      end

      should 'raise an exception if a commit is requested but the unit is not started' do
        assert_raises RuntimeError do
          @uow.commit
        end
      end

      should 'keep an identity map for aggregates of the same type and identifier' do
        aggregate_a = TestAggregateA.new 1
        aggregate_b = TestAggregateB.new 2
        aggregate_c = TestAggregateB.new 3
        aggregate_d = TestAggregateB.new 3

        event_bus = Object.new
        storage_listener = Object.new

        assert_same aggregate_a, @uow.register_aggregate(aggregate_a, event_bus, storage_listener)
        assert_same aggregate_b, @uow.register_aggregate(aggregate_b, event_bus, storage_listener)
        assert_same aggregate_c, @uow.register_aggregate(aggregate_c, event_bus, storage_listener)
        assert_same aggregate_c, @uow.register_aggregate(aggregate_d, event_bus, storage_listener)
      end

      should 'interact with a transaction manager on commit' do
        listener = UnitOfWorkListener.new

        tx = Object.new
        txm = Object.new
        mock(txm).start {
          tx
        }

        mock(listener).on_start(@uow).ordered
        mock(listener).on_prepare_commit(@uow, anything, anything).ordered
        mock(listener).on_prepare_transaction_commit(@uow, tx).ordered
        mock(txm).commit(tx).ordered
        mock(listener).after_commit(@uow).ordered
        mock(listener).on_cleanup(@uow).ordered

        @uow.transaction_manager = txm
        @uow.register_listener listener
        @uow.start

        @uow.commit
      end

      should 'interact with a transaction manager on rollback' do
        listener = UnitOfWorkListener.new

        tx = Object.new
        txm = Object.new
        mock(txm).start {
          tx
        }

        mock(listener).on_start(@uow).ordered
        mock(txm).rollback(tx).ordered
        mock(listener).on_rollback(@uow, nil).ordered
        mock(listener).on_cleanup(@uow).ordered

        @uow.transaction_manager = txm
        @uow.register_listener listener
        @uow.start

        @uow.rollback
      end

      should 'register a listener with the current unit of work if it is unaware of nesting' do
        outer_unit = Object.new
        mock(outer_unit).register_listener(is_a(OuterCommitUnitOfWorkListener))
        mock(outer_unit).rollback

        @provider.push outer_unit

        inner_unit = create_uow

        inner_unit.rollback
        outer_unit.rollback

        @provider.clear outer_unit
      end

      should 'roll back inner units if the outer unit is rolled back' do
        outer_unit = create_uow
        inner_unit = create_uow

        listener = UnitOfWorkListener.new
        mock(listener).on_rollback(inner_unit, nil)

        inner_unit.register_listener listener

        inner_unit.commit
        outer_unit.rollback
      end

      should 'commit inner units after the outer unit is committed' do
        outer_unit = create_uow
        inner_unit = create_uow

        committed = false

        listener = UnitOfWorkListener.new
        mock(listener).after_commit(inner_unit) {
          committed = true
        }

        inner_unit.register_listener listener
        inner_unit.commit

        refute committed, 'Inner unit was committed prematurely'

        outer_unit.commit

        assert committed, 'Inner unit should have been committed'
      end

      should 'rollback if a listener raises an exception while preparing to commit' do
        cause = TestError.new
        listener = UnitOfWorkListener.new

        mock(listener).on_prepare_commit(@uow, anything, anything) {
          raise cause
        }
        mock(listener).on_rollback(@uow, cause)
        mock(listener).after_commit.never
        mock(listener).on_cleanup(@uow)

        @uow.register_listener listener
        @uow.start

        assert_raises TestError do
          @uow.commit
        end
      end

      should 'rollback if an aggregate storage listener raises an exception' do
        aggregate_root = Object.new
        mock(aggregate_root).add_registration_listener
        mock(aggregate_root).id

        event_bus = Object.new
        cause = TestError.new

        storage_listener = Object.new
        mock(storage_listener).store(aggregate_root) {
          raise cause
        }

        listener = UnitOfWorkListener.new
        mock(listener).on_prepare_commit(@uow, anything, anything)
        mock(listener).on_rollback(@uow, cause)
        mock(listener).after_commit.never
        mock(listener).on_cleanup(@uow)

        @uow.start
        @uow.register_listener listener
        @uow.register_aggregate aggregate_root, event_bus, storage_listener

        assert_raises TestError do
          @uow.commit
        end
      end

      should 'rollback if the event bus raises an exception when publishing events' do
        cause = TestError.new
        event = Object.new

        event_bus = Object.new
        mock(event_bus).publish([event]) {
          raise cause
        }

        listener = UnitOfWorkListener.new
        mock(listener).on_event_registered(@uow, event) {
          event
        }
        mock(listener).after_commit.never

        @uow.start
        @uow.register_listener listener
        @uow.publish_event event, event_bus

        assert_raises TestError do
          @uow.commit
        end
      end

      should 'delay cleanup of inner unit after commit until outer unit is committed' do
        outer_listener = UnitOfWorkListener.new
        inner_listener = UnitOfWorkListener.new

        outer_unit = create_uow
        inner_unit = create_uow

        outer_unit.register_listener outer_listener
        inner_unit.register_listener inner_listener

        mock(inner_listener).after_commit(inner_unit).ordered
        mock(outer_listener).after_commit(outer_unit).ordered
        mock(inner_listener).on_cleanup(inner_unit).ordered
        mock(outer_listener).on_cleanup(outer_unit).ordered

        inner_unit.commit
        outer_unit.commit
      end

      should 'delay cleanup of inner unit after rollback until outer unit is committed' do
        outer_listener = UnitOfWorkListener.new
        inner_listener = UnitOfWorkListener.new

        outer_unit = create_uow
        inner_unit = create_uow

        outer_unit.register_listener outer_listener
        inner_unit.register_listener inner_listener

        mock(inner_listener).on_rollback(inner_unit, nil).ordered
        mock(outer_listener).after_commit(outer_unit).ordered
        mock(inner_listener).on_cleanup(inner_unit).ordered
        mock(outer_listener).on_cleanup(outer_unit).ordered

        inner_unit.rollback
        outer_unit.commit
      end

      should 'delay cleanup of inner unit after commit until outer unit is rolled back' do
        outer_listener = UnitOfWorkListener.new
        inner_listener = UnitOfWorkListener.new

        outer_unit = create_uow
        inner_unit = create_uow

        outer_unit.register_listener outer_listener
        inner_unit.register_listener inner_listener

        mock(inner_listener).on_prepare_commit(inner_unit, anything, anything).ordered
        mock(inner_listener).on_rollback(inner_unit, nil).ordered
        mock(outer_listener).on_rollback(outer_unit, nil).ordered
        mock(inner_listener).on_cleanup(inner_unit).ordered
        mock(outer_listener).on_cleanup(outer_unit).ordered

        inner_unit.commit
        outer_unit.rollback
      end

      should 'raise an exception if a transaction manager is set after the unit has been started' do
        @uow.start

        assert_raises RuntimeError do
          @uow.transaction_manager = Object.new
        end

        @uow.commit
      end

      should 'not put the unit of work provider into a bad state if the unit of work fails during start' do
        txm = Object.new
        mock(txm).start {
          raise 'Something bad happened'
        }

        @uow.transaction_manager = txm

        begin
          @uow.start
        rescue RuntimeError; end

        refute @provider.started?
      end

      should 'continually publish events as events are published' do
        @uow.start

        event_bus = EventBus::SimpleEventBus.new

        event_a = Domain::EventMessage.build
        event_b = Domain::EventMessage.build

        listener = Object.new
        mock(listener).notify(event_a) {
          @uow.publish_event event_b, event_bus
        }
        mock(listener).notify(event_b)

        event_bus.subscribe listener

        @uow.publish_event event_a, event_bus
        @uow.commit
      end

    private

      def create_uow
        uow = UnitOfWork.new @provider
        uow.start
        uow
      end
    end

    class TestError < StandardError; end

    class TestAggregateA
      include Domain::AggregateRoot
      def initialize(id)
        @id = id
      end
    end
    class TestAggregateB
      include Domain::AggregateRoot
      def initialize(id)
        @id = id
      end
    end
  end
end
