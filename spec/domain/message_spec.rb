require 'spec_helper'

module Synapse
  module Domain

    describe EventMessage do
      it 'wraps event objects into event messages' do
        event = Object.new
        message = EventMessage.build

        EventMessage.as_message(message).should be(message)

        wrapped = EventMessage.as_message(event)
        wrapped.should be_a(EventMessage)
        wrapped.payload.should be(event)
      end
    end

    describe DomainEventMessage do
      before do
        @payload = OpenStruct.new
        @aggregate_id = 123
        @sequence_number = 1

        @message = DomainEventMessage.build do |b|
          b.payload = @payload
          b.aggregate_id = @aggregate_id
          b.sequence_number = @sequence_number
        end
      end

      it 'populates fields with sensible defaults' do
        # ensure empty fields were populated with default values
        @message.id.should be_a(String)
        @message.metadata.should be_a(Hash)
        @message.timestamp.should be_a(Time)

        # ensure other fields were populated
        @message.payload.should == @payload
        @message.payload_type.should == @payload.class
        @message.aggregate_id.should == @aggregate_id
        @message.sequence_number.should == @sequence_number
      end

      it 'returns itself when merging an empty metadata hash' do
        @message.and_metadata(Hash.new).should be(@message)
      end

      it 'creates a complete copy of itself when merging metadata' do
        additional_metadata_a = { foo: 'bar' }
        additional_metadata_b = { baz: 'qux' }

        merged = @message.and_metadata additional_metadata_a
        merged = merged.and_metadata additional_metadata_b

        # Ensure everything was populated in the duplicate message
        ensure_message_content_equal merged

        # Now ensure that metadata was merged, not replaced
        merged.metadata.should == additional_metadata_a.merge(additional_metadata_b)
      end

      it 'returns itself when replacing an empty metadata hash' do
        @message.with_metadata(Hash.new).should be(@message)
      end

      it 'creates a complete copy of itself when replacing metadata' do
        additional_metadata_a = { foo: 'bar' }
        additional_metadata_b = { baz: 'qux' }

        merged = @message.with_metadata additional_metadata_a
        merged = merged.with_metadata additional_metadata_b

        ensure_message_content_equal merged

        # Ensure that the metadata was replaced
        merged.metadata.should == additional_metadata_b
      end

    private

      def ensure_message_content_equal(merged)
        merged.id.should == @message.id
        merged.payload.should == @message.payload
        merged.timestamp.should == @message.timestamp
        merged.aggregate_id.should == @message.aggregate_id
        merged.sequence_number.should == @message.sequence_number
      end
    end

  end
end
