require 'test_helper'
require 'serialization/fixtures'

module Synapse
  module Serialization

    class OjSerializerTest < Test::Unit::TestCase

      def test_serialize_deserialize
        serializer = OjSerializer.new
        event = TestEvent.new 'derp', 'herp'

        serialized_obj = serializer.serialize event, String
        deserialized = serializer.deserialize serialized_obj

        assert_equal event, deserialized
      end

    end

  end
end
