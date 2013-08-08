require 'spec_helper'

module Synapse
  module Domain

    describe SimpleDomainEventStream do
      subject {
        SimpleDomainEventStream.new DomainEventMessage.build, DomainEventMessage.build
      }

      it 'supports peeking without moving the pointer forward' do
        first = subject.peek
        subject.peek.should == first
        subject.peek.should == first
      end

      it 'raises an exception when the end of the stream is reached' do
        subject.next_event
        subject.next_event

        expect {
          subject.next_event
        }.to raise_error EndOfStreamError

        expect {
          subject.peek
        }.to raise_error EndOfStreamError
      end
    end

  end
end
