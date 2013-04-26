require 'test_helper'

module Synapse
  module Serialization
    class SerializedTypeTest < Test::Unit::TestCase

      def test_attributes
        type = SerializedType.new 'SomeClass', '1'

        assert_equal 'SomeClass', type.name
        assert_equal '1', type.revision
      end

      def test_object_equality
        a = SerializedType.new 'SomeClass', '1'
        b = SerializedType.new 'SomeClass', '1'
        c = SerializedType.new 'SomeClass', '2'

        assert_equal a, b
        refute_equal a, c
        assert_equal a.hash, b.hash
        refute_equal a.hash, c.hash
      end

    end
  end
end
