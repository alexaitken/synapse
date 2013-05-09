require 'test_helper'

module Synapse
  module Serialization

    class SerializedMessageTest < Test::Unit::TestCase
      def test_build
        message = SerializedMessage.build do |builder|
          assert builder.is_a? SerializedMessageBuilder
        end
        assert message.is_a? SerializedMessage
      end
    end

    class SerializedEventMessageTest < Test::Unit::TestCase
      def test_build
        message = SerializedEventMessage.build do |builder|
          assert builder.is_a? SerializedEventMessageBuilder
        end
        assert message.is_a? SerializedEventMessage
      end
    end

    class SerializedDomainEventMessageTest < Test::Unit::TestCase
      def setup
        @serializer_a = MarshalSerializer.new
        @serializer_b = MarshalSerializer.new
      end

      def test_serialization
        metadata = { foo: 0 }
        payload = { bar: 1 }

        metadata_serialized = @serializer_a.serialize metadata, String
        payload_serialized = @serializer_a.serialize payload, String

        metadata_lazy = LazyObject.new metadata_serialized, @serializer_a
        payload_lazy = LazyObject.new payload_serialized, @serializer_a

        message = SerializedDomainEventMessage.build do |builder|
          builder.metadata = metadata_lazy
          builder.payload = payload_lazy
        end

        refute message.serialized_metadata.deserialized?
        assert_equal metadata, message.metadata

        assert_equal Hash, message.payload_type
        refute message.serialized_payload.deserialized?

        assert_equal payload, message.payload
        assert message.serialized_payload.deserialized?

        metadata_serialized_a = message.serialize_metadata @serializer_a, String
        assert_same metadata_serialized, metadata_serialized_a
        payload_serialized_a = message.serialize_payload @serializer_a, String
        assert_same payload_serialized, payload_serialized_a

        metadata_serialized_b = message.serialize_metadata @serializer_b, String
        assert_equal metadata_serialized, metadata_serialized_b
        payload_serialized_b = message.serialize_payload @serializer_b, String
        assert_equal payload_serialized, payload_serialized_b
      end

      def test_and_metadata
        metadata = { foo: 0 }
        payload = { bar: 1 }

        metadata_serialized = @serializer_a.serialize metadata, String
        metadata_lazy = LazyObject.new metadata_serialized, @serializer_a
        payload_serialized = @serializer_a.serialize metadata, String
        payload_lazy = LazyObject.new payload_serialized, @serializer_a

        message = SerializedDomainEventMessage.build do |builder|
          builder.id = 1
          builder.metadata = metadata_lazy
          builder.payload = payload_lazy
          builder.timestamp = Time.now
          builder.aggregate_id = 2
          builder.sequence_number = 3
        end

        new_message = message.and_metadata Hash.new
        assert_same message, new_message

        new_message = message.and_metadata baz: 3

        merged = {
          foo: 0,
          baz: 3
        }

        assert_equal merged, new_message.metadata
        assert_message_content_equal message, new_message
      end

      def test_with_metadata
        metadata = { foo: 0 }
        payload = { bar: 1 }

        metadata_serialized = @serializer_a.serialize metadata, String
        metadata_lazy = LazyObject.new metadata_serialized, @serializer_a
        payload_serialized = @serializer_a.serialize metadata, String
        payload_lazy = LazyObject.new payload_serialized, @serializer_a

        message = SerializedDomainEventMessage.build do |builder|
          builder.id = 1
          builder.metadata = metadata_lazy
          builder.payload = payload_lazy
          builder.timestamp = Time.now
          builder.aggregate_id = 2
          builder.sequence_number = 3
        end

        new_message = message.with_metadata foo: 0
        assert_same message, new_message

        new_message = message.with_metadata baz: 3

        replaced = {
          baz: 3
        }

        assert_equal replaced, new_message.metadata
        assert_message_content_equal message, new_message
      end

    private

      def assert_message_content_equal(expected, actual)
        assert_equal expected.id, actual.id
        assert_equal expected.serialized_payload, actual.serialized_payload
        assert_equal expected.timestamp, actual.timestamp
        assert_equal expected.aggregate_id, actual.aggregate_id
        assert_equal expected.sequence_number, actual.sequence_number
      end
    end

  end
end
