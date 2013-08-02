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

      it 'supports peeking without moving the pointer forward' do
        @stream.peek.should == @events[0]
        @stream.peek.should == @events[0]
      end

      it 'raises an exception when the end of the stream is reached' do
        @stream.next_event
        @stream.next_event

        expect {
          @stream.next_event
        }.to raise_error EndOfStreamError

        expect {
          @stream.peek
        }.to raise_error EndOfStreamError
      end
    end

  end
end
