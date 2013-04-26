require 'test_helper'
require 'serializer/fixtures'

module Synapse
  module Serialization
    class LazyObjectTest < Test::Unit::TestCase
      def test_deserialize_once
        serializer = MarshalSerializer.new
        event = TestEvent.new 'a', 'b'

        serialized = serializer.serialize event, String

        lazy = LazyObject.new serialized, serializer

        assert_equal serialized, lazy.serialized_object
        assert_equal serializer, lazy.serializer
        assert_equal TestEvent, lazy.type

        refute lazy.deserialized?

        deserialized_a = lazy.deserialized
        deserialized_b = lazy.deserialized

        assert deserialized_a === deserialized_b
        assert deserialized_a == event
        assert deserialized_b == event

        assert lazy.deserialized?
      end
    end
  end
end
