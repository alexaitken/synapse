require 'test_helper'

module Synapse
  module Serialization
    class SerializedDomainEventMessageTest < Test::Unit::TestCase
      def setup
        @metadata = { foo: 'bar' }
        @payload = { baz: 'qux' }

        @serializer = MarshalSerializer.new
        @serialized_metadata = @serializer.serialize @metadata, String
        @serialized_payload = @serializer.serialize @payload, String

        @message = SerializedDomainEventMessage.new do |m|
          m.id = SecureRandom.uuid
          m.with_serialized @serialized_metadata, @serialized_payload, @serializer
          m.timestamp = Time.now
          m.aggregate_id = SecureRandom.uuid
          m.sequence_number = 1
        end
      end

      def test_deserialization
        assert_equal @metadata, @message.metadata
        assert_equal @payload, @message.payload
      end

      def test_payload_type
        assert_equal Hash, @message.payload_type
        refute @message.serialized_payload.deserialized?
      end

      def test_and_metadata
        additional_metadata = { derp: 'herp' }

        merged = @message.and_metadata additional_metadata

        # Ensure everything was populated in the duplicate message
        assert_equal @message.id, merged.id
        assert_equal @message.payload, merged.payload
        assert_equal @message.timestamp, merged.timestamp
        assert_equal @message.aggregate_id, merged.aggregate_id
        assert_equal @message.sequence_number, merged.sequence_number

        # Now ensure that metadata was merged, not replaced
        assert_equal @metadata.merge(additional_metadata), merged.metadata
      end

      def test_with_metadata
        new_metadata = { derp: 'herp' }

        merged = @message.with_metadata new_metadata

        # Ensure everything was populated in the duplicate message
        assert_equal @message.id, merged.id
        assert_equal @message.payload, merged.payload
        assert_equal @message.timestamp, merged.timestamp
        assert_equal @message.aggregate_id, merged.aggregate_id
        assert_equal @message.sequence_number, merged.sequence_number

        # Ensure that the metadata was replaced
        assert_equal new_metadata, merged.metadata
      end

      def test_serialize
        other_serializer = MarshalSerializer.new

        assert @message.serialize_metadata(@serializer, String).equal? @serialized_metadata
        refute @message.serialize_metadata(other_serializer, String).equal? @serialized_metadata

        assert @message.serialize_payload(@serializer, String).equal? @serialized_payload
        refute @message.serialize_payload(other_serializer, String).equal? @serialized_payload
      end
    end
  end
end
