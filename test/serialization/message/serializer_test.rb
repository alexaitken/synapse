require 'test_helper'

module Synapse
  module Serialization
    class MessageSerializerTest < Test::Unit::TestCase
      def test_serialize
        delegate = Object.new
        serializer = MessageSerializer.new delegate

        metadata = Hash.new
        payload = Object.new

        m = MessageBuilder.build do |b|
          b.metadata = metadata
          b.payload = payload
        end

        serialized_metadata = Object.new
        serialized_payload = Object.new

        mock(delegate).serialize(metadata, String) do
          serialized_metadata
        end
        mock(delegate).serialize(payload, String) do
          serialized_payload
        end

        assert_equal serialized_metadata, serializer.serialize_metadata(m, String)
        assert_equal serialized_payload, serializer.serialize_payload(m, String)
      end

      def test_serialization_aware
        delegate = Object.new
        serializer = MessageSerializer.new delegate

        stub_class = Class.new do
          include SerializationAware
        end

        stub = stub_class.new

        mock(stub).serialize_metadata(delegate, String)
        mock(stub).serialize_payload(delegate, String)

        serializer.serialize_metadata(stub, String)
        serializer.serialize_payload(stub, String)
      end
    end
  end
end
