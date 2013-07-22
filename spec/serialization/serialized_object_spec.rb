require 'spec_helper'

module Synapse
  module Serialization
    
    describe SerializedObject do
      it 'provides correct attributes' do
        content = 'some content'
        type = SerializedType.new 'SomeClass', '1'

        object = SerializedObject.new content, content.class, type

        object.content.should be(content)
        object.content_type.should be(content.class)
        object.type.should be(type)
      end

      it 'supports object equality and hashing' do
        type_a = SerializedType.new 'SomeClass', '1'
        type_b = SerializedType.new 'SomeClass', '2'

        a = SerializedObject.new 'content', String, type_a
        b = SerializedObject.new 'content', String, type_a
        c = SerializedObject.new 'content', String, type_b
        d = SerializedObject.new 'content_derp', String, type_a

        a.should == b
        b.should == a
        a.should_not == c
        a.should_not == d
        
        a.hash.should == b.hash
        a.hash.should_not == c.hash
        a.hash.should_not == d.hash
      end
    end
    
  end
end
