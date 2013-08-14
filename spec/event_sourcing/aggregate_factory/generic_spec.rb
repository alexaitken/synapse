require 'spec_helper'
require 'event_sourcing/fixtures'

module Synapse
  module EventSourcing

    describe GenericAggregateFactory do
      subject do
        GenericAggregateFactory.new StubAggregate
      end

      it 'creates an aggregate from a normal event' do
        event = Domain.build_message do |m|
          m.payload = StubCreatedEvent.new 123
        end

        aggregate = subject.create_aggregate 123, event
        aggregate.should be_a StubAggregate
      end

      it 'uses an aggregate snapshot if available' do
        snapshot = StubAggregate.new 123
        snapshot.do_something
        snapshot.mark_committed

        snapshot_event = Domain.build_message do |m|
          m.payload = snapshot
        end

        aggregate = subject.create_aggregate 123, snapshot_event

        aggregate.should == snapshot
        aggregate.initial_version.should == snapshot.version
      end
    end

  end
end

