require 'spec_helper'

module Synapse

  describe Message do
    it 'wraps bare payload objects as messages' do
      object = ExamplePayload.new

      wrapped = Message.as_message(object)
      wrapped.should be_a(Message)
      wrapped.payload.should be(object)

      object = Message.build do |b|
        b.payload = ExamplePayload.new
      end

      wrapped = Message.as_message(object)
      wrapped.should be(object)
    end

    context 'when merging metadata' do
      it 'creates a duplicate with the merged metadata' do
        message = Message.build do |b|
          b.metadata = { foo: 0 }
          b.payload = ExamplePayload.new
        end

        new_message = message.and_metadata(bar: 1)

        new_message.id.should == message.id
        new_message.metadata.should == { foo: 0, bar: 1 }
        new_message.payload.should == message.payload
        new_message.timestamp.should == message.timestamp
      end

      it 'returns itself when the given metadata is empty' do
        message = Message.build

        new_message = message.and_metadata Hash.new
        new_message.should be(message)
      end
    end

    context 'when replacing metadata' do
      it 'creates a duplicate with the replacement metadata' do
        message = Message.build do |b|
          b.metadata = { foo: 0 }
          b.payload = ExamplePayload.new
        end

        new_message = message.with_metadata(bar: 1)

        new_message.id.should == message.id
        new_message.metadata.should == { bar: 1 }
        new_message.payload.should == message.payload
        new_message.timestamp.should == message.timestamp
      end

      it 'returns itself when the replacement metadata is the same' do
        metadata = { foo: 0 }
        message = Message.build do |b|
          b.metadata = metadata
        end

        new_message = message.with_metadata(metadata)
        new_message.should be(message)
      end
    end
  end

  ExamplePayload = Class.new

end
