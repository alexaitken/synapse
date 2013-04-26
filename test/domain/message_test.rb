require 'test_helper'

module Synapse
  module Domain
    class DomainEventMessageTest < Test::Unit::TestCase
      def setup
        @payload = OpenStruct.new
        @aggregate_id = 123
        @sequence_number = 1

        @message = DomainEventMessage.new do |m|
          m.payload = @payload
          m.aggregate_id = @aggregate_id
          m.sequence_number = @sequence_number
        end
      end

      def test_initialize
        # ensure empty fields were populated with default values
        assert @message.id
        assert @message.metadata
        assert @message.timestamp

        # ensure other fields were populated
        assert_equal @payload, @message.payload
        assert_equal @payload.class, @message.payload_type
        assert_equal @aggregate_id, @message.aggregate_id
        assert_equal @sequence_number, @message.sequence_number

        # ensure message is properly frozen
        assert @message.frozen?
        assert @message.metadata.frozen?
        assert @message.payload.frozen?
      end

      def test_and_metadata
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

      def test_with_metadata
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
