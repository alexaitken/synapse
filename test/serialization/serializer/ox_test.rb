require 'test_helper'
require 'serialization/fixtures'

module Synapse
  module Serialization

    class OxSerializerTest < Test::Unit::TestCase
      def setup
        skip 'Ox not supported on JRuby' if defined? JRUBY_VERSION

        @serializer = OxSerializer.new
      end

      def test_serialize_and_deserialize
        event = TestEvent.new 'derp', 'herp'

        serialized_obj = @serializer.serialize event, String
        deserialized = @serializer.deserialize serialized_obj

        assert_equal event, deserialized
      end

      def test_type_converison
        type = SerializedType.new 'String', nil

        assert_equal String, @serializer.class_for(type)
        assert_equal type, @serializer.type_for(String)

        assert_raise UnknownSerializedTypeError do
          @serializer.class_for(SerializedType.new('NonExistentClass', nil))
        end
      end
    end

  end
end
