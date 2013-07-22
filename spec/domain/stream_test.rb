require 'spec_helper'

module Synapse
  module Domain
    describe SimpleDomainEventStream do

      before do
        @events = Array.new
        @events.push DomainEventMessage.build
        @events.push DomainEventMessage.build

        @stream = SimpleDomainEventStream.new @events
      end

      it 'support peeking without moving the pointer forward' do
        assert_same @events.at(0), @stream.peek
        assert_same @events.at(0), @stream.peek
      end

      it 'raise an exception when the end of the stream is reached' do
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
