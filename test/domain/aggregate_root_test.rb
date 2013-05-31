require 'test_helper'
require 'domain/fixtures'

module Synapse
  module Domain
    class AggregateRootTest < Test::Unit::TestCase

      def setup
        @person = Person.new 123, 'Fry'
      end

      should 'track published events' do
        assert_equal 0, @person.uncommitted_event_count

        @person.change_name 'Leela'

        events = Array.new

        @person.add_registration_listener do |event|
          events.push event
          event
        end

        @person.change_name 'Bender'

        assert_equal 2, @person.uncommitted_event_count
        assert_equal events, @person.uncommitted_events.to_a
      end

      should 'handle being marked committed' do
        @person.change_name 'Bender'
        @person.mark_committed

        assert_equal 0, @person.uncommitted_event_count
      end

      should 'handle being marked for deletion' do
        @person.delete

        assert @person.deleted?
      end

      should 'raise an exception if identifier not initialized, but events are applied' do
        p = Person.new nil, nil

        assert_raise AggregateIdentifierNotInitializedError do
          p.change_name 'Zoidberg'
        end
      end

      should 'return an empty domain event stream if no events have been published' do
        assert @person.uncommitted_events.end?
      end

    end
  end
end
