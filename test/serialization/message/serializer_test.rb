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
    end
  end
end
