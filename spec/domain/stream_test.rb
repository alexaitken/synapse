require 'test_helper'

module Synapse
  module Domain
    describe SimpleDomainEventStream do

      def setup
        @events = Array.new
        @events.push DomainEventMessage.build
        @events.push DomainEventMessage.build

        @stream = SimpleDomainEventStream.new @events
      end

      should 'support peeking without moving the pointer forward' do
        assert_same @events.at(0), @stream.peek
        assert_same @events.at(0), @stream.peek
      end

      should 'raise an exception when the end of the stream is reached' do
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
