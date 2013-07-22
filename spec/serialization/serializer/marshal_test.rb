require 'test_helper'
require 'serialization/fixtures'

module Synapse
  module Serialization

    class MarshalSerializerTest < Test::Unit::TestCase
      should 'support serializing and deserializing content' do
        serializer = MarshalSerializer.new ConverterFactory.new
        event = TestEvent.new 'derp', 'herp'

        serialized_obj = serializer.serialize event, String
        deserialized = serializer.deserialize serialized_obj

        assert_equal event, deserialized
      end
    end

  end
end
