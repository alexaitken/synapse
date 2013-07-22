require 'test_helper'

module Synapse
  module Domain
    describe EventMessage do
      should 'wrap event objects into event messages' do
        event = Object.new
        event_message = EventMessage.build

        assert_same event_message, EventMessage.as_message(event_message)

        wrapped = EventMessage.as_message(event)
        assert_same event, wrapped.payload
      end
    end

    describe DomainEventMessage do
      def setup
        @payload = OpenStruct.new
        @aggregate_id = 123
        @sequence_number = 1

        @message = DomainEventMessage.build do |b|
          b.payload = @payload
          b.aggregate_id = @aggregate_id
          b.sequence_number = @sequence_number
        end
      end

      should 'populate fields with sensible defaults' do
        # ensure empty fields were populated with default values
        assert @message.id
        assert @message.metadata
        assert @message.timestamp

        # ensure other fields were populated
        assert_equal @payload, @message.payload
        assert_equal @payload.class, @message.payload_type
        assert_equal @aggregate_id, @message.aggregate_id
        assert_equal @sequence_number, @message.sequence_number
      end

      should 'create a complete copy of itself when merging metadata' do
        additional_metadata_a = { foo: 'bar' }
        additional_metadata_b = { baz: 'qux' }

        merged = @message.and_metadata additional_metadata_a
        merged = merged.and_metadata additional_metadata_b

        # Ensure everything was populated in the duplicate message
        assert_equal @message.id, merged.id
        assert_equal @message.payload, merged.payload
        assert_equal @message.timestamp, merged.timestamp
        assert_equal @message.aggregate_id, merged.aggregate_id
        assert_equal @message.sequence_number, merged.sequence_number

        # Now ensure that metadata was merged, not replaced
        assert_equal additional_metadata_a.merge(additional_metadata_b), merged.metadata
      end

      should 'create a complete copy of itself when replacing metadata' do
        additional_metadata_a = { foo: 'bar' }
        additional_metadata_b = { baz: 'qux' }

        merged = @message.with_metadata additional_metadata_a
        merged = merged.with_metadata additional_metadata_b

        # Ensure that the metadata was replaced
        assert_equal additional_metadata_b, merged.metadata
      end
    end
  end
end
