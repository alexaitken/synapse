require 'spec_helper'
require 'domain/fixtures'

module Synapse
  module Domain

    describe AggregateRoot do
      subject do
        Person.new 123, 'Fry'
      end

      it 'tracks published events' do
        subject.uncommitted_event_count.should == 0

        subject.change_name 'Leela'

        events = Array.new

        subject.add_registration_listener do |event|
          events.push event
          event
        end

        subject.change_name 'Bender'

        subject.uncommitted_event_count.should == 2
        subject.uncommitted_events.to_a.should == events
      end

      it 'commits the underlying event container' do
        subject.change_name 'Bender'
        subject.mark_committed

        subject.uncommitted_event_count.should == 0
      end

      it 'handles being marked for deletion' do
        subject.delete
        subject.should be_deleted
      end

      it 'raises an exception if identifier not initialized, but events are applied' do
        p = Person.allocate

        expect {
          p.change_name 'Zoidberg'
        }.to raise_error AggregateIdentifierNotInitializedError
      end

      it 'returns an empty domain event stream if no events have been published' do
        subject.uncommitted_events.should be_end
      end
    end

  end
end
