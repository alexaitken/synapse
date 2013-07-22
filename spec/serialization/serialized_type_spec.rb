require 'spec_helper'

module Synapse
  module Serialization
    
    describe SerializedType do
      it 'provides correct attributes' do
        type = SerializedType.new 'SomeClass', '1'

        type.name.should == 'SomeClass'
        type.revision.should == '1'
      end

      it 'supports object equality and hashing' do
        a = SerializedType.new 'SomeClass', '1'
        b = SerializedType.new 'SomeClass', '1'
        c = SerializedType.new 'SomeClass', '2'
        
        a.should == b
        b.should == a
        a.should_not == c
        
        a.hash.should == b.hash
        a.hash.should_not == c.hash
      end
    end
    
  end
end
