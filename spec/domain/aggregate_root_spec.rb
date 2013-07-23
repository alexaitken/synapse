require 'spec_helper'
require 'domain/fixtures'

module Synapse
  module Domain

    describe AggregateRoot do
      before do
        @person = Person.new 123, 'Fry'
      end

      it 'tracks published events' do
        @person.uncommitted_event_count.should == 0

        @person.change_name 'Leela'

        events = Array.new

        @person.add_registration_listener do |event|
          events.push event
          event
        end

        @person.change_name 'Bender'

        @person.uncommitted_event_count.should == 2
        @person.uncommitted_events.to_a.should == events
      end

      it 'commits the underlying event container' do
        @person.change_name 'Bender'
        @person.mark_committed

        @person.uncommitted_event_count.should == 0
      end

      it 'handles being marked for deletion' do
        @person.delete

        expect(@person.deleted?).to be_true
      end

      it 'raises an exception if identifier not initialized, but events are applied' do
        p = Person.new nil, nil

        expect {
          p.change_name 'Zoidberg'
        }.to raise_error(AggregateIdentifierNotInitializedError)
      end

      it 'returns an empty domain event stream if no events have been published' do
        expect(@person.uncommitted_events.end?).to be_true
      end
    end

  end
end
