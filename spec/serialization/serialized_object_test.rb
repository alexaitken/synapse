require 'test_helper'

module Synapse
  module Serialization
    
    class SerializedObjectTest < Test::Unit::TestCase
      should 'provide initialized fields' do
        content = 'some content'
        type = SerializedType.new 'SomeClass', '1'

        object = SerializedObject.new content, content.class, type

        assert_equal content, object.content
        assert_equal content.class, object.content_type
        assert_equal type, object.type
      end

      should 'support object equality and hashing' do
        type_a = SerializedType.new 'SomeClass', '1'
        type_b = SerializedType.new 'SomeClass', '2'

        a = SerializedObject.new 'content', String, type_a
        b = SerializedObject.new 'content', String, type_a
        c = SerializedObject.new 'content', String, type_b
        d = SerializedObject.new 'content_derp', String, type_a

        assert_equal a, b
        refute_equal a, c
        refute_equal a, d

        assert_equal a.hash, b.hash
      end
    end
    
  end
end
