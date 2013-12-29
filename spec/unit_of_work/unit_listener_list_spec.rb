require 'spec_helper'

module Synapse
  module UnitOfWork

    describe UnitListenerList do
      before do
        @listener_a = Object.new
        @listener_b = Object.new
        @unit = Object.new

        subject.push @listener_a
        subject.push @listener_b
      end

      it 'notifies listeners of on_event_registered in the correct precedence' do
        event_in = Object.new
        event_intermediate = Object.new
        event_out = Object.new

        mock(@listener_a).on_event_registered(@unit, event_in).returns(event_intermediate)
        mock(@listener_b).on_event_registered(@unit, event_intermediate).returns(event_out)

        subject.on_event_registered(@unit, event_in).should == event_out
      end

      it 'notifies listeners of on_prepare_commit in the correct precedence' do
        aggregates = []
        events = {}

        mock(@listener_a).on_prepare_commit(@unit, aggregates, events).ordered
        mock(@listener_b).on_prepare_commit(@unit, aggregates, events).ordered

        subject.on_prepare_commit @unit, aggregates, events
      end

      it 'notifies listeners of on_prepare_transaction_commit in the correct precedence' do
        transaction = Object.new

        mock(@listener_a).on_prepare_transaction_commit(@unit, transaction).ordered
        mock(@listener_b).on_prepare_transaction_commit(@unit, transaction).ordered

        subject.on_prepare_transaction_commit @unit, transaction
      end

      it 'notifies listeners of after_commit in the correct precedence' do
        mock(@listener_b).after_commit(@unit).ordered
        mock(@listener_a).after_commit(@unit).ordered

        subject.after_commit @unit
      end

      it 'notifies listeners of on_rollback in the correct precedence' do
        cause = RuntimeError.new

        mock(@listener_b).on_rollback(@unit, cause).ordered
        mock(@listener_a).on_rollback(@unit, cause).ordered

        subject.on_rollback @unit, cause
      end

      it 'notifies listeners of on_cleanup in the correct precedence' do
        mock(@listener_b).on_cleanup(@unit).ordered
        mock(@listener_a).on_cleanup(@unit).ordered

        subject.on_cleanup @unit
      end

      it 'suppresses exceptions from listeners during on_cleanup' do
        mock(@listener_b).on_cleanup(@unit).ordered do
          raise RuntimeError
        end
        mock(@listener_a).on_cleanup(@unit).ordered do
          raise RuntimeError
        end

        subject.on_cleanup @unit
      end
    end

  end
end
