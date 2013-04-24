require 'test_helper'

module Synapse
  module Domain
    class SimpleDomainEventStreamTest < Test::Unit::TestCase

      def setup
        @events = Array.new
        @events << DomainEventMessage.new
        @events << DomainEventMessage.new

        @stream = SimpleDomainEventStream.new @events
      end

      def test_peek
        assert_same @events.at(0), @stream.peek
        assert_same @events.at(0), @stream.peek
      end

      def test_end_of_stream
        @stream.next_event
        @stream.next_event

        assert_raise EndOfStreamError do
          @stream.next_event
        end

        assert_raise EndOfStreamError do
          @stream.peek
        end
      end

    end
  end
end
