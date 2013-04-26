require 'test_helper'
require 'serializer/fixtures'

module Synapse
  module Serialization

    class MarshalSerializerTest < Test::Unit::TestCase

      def test_serialize_deserialize
        serializer = MarshalSerializer.new
        event = TestEvent.new 'derp', 'herp'

        serialized_obj = serializer.serialize event, String
        deserialized = serializer.deserialize serialized_obj

        assert_equal event, deserialized
      end

    end

  end
end
