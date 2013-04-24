require 'test_helper'
require 'domain/fixtures'

module Synapse
  module Domain
    class AggregateRootTest < Test::Unit::TestCase

      def setup
        @person = Person.new 123, 'Fry'
      end

      def test_publish_events
        assert_equal 0, @person.uncommitted_event_count

        @person.change_name 'Leela'

        events = Array.new

        @person.add_registration_listener do |event|
          events << event
          event
        end

        @person.change_name 'Bender'

        assert_equal 2, @person.uncommitted_event_count
        assert_equal events, @person.uncommitted_events.to_a
      end

      def test_mark_committed
        @person.change_name 'Bender'
        @person.mark_committed

        assert_equal 0, @person.uncommitted_event_count
      end

      def test_mark_deleted
        @person.delete

        assert @person.deleted?
      end

      def test_identifier_not_initialized
        p = Person.new nil, nil

        assert_raise AggregateIdentifierNotInitializedError do
          p.change_name 'Zoidberg'
        end
      end

      def test_empty_uncommitted_events
        assert @person.uncommitted_events.end?
      end

    end
  end
end
