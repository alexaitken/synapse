require 'spec_helper'
require 'serialization/fixtures'

module Synapse
  module Serialization
    
    describe LazyObject do
      it 'only deserializes an object once' do
        serializer = MarshalSerializer.new ConverterFactory.new
        event = TestEvent.new 'a', 'b'

        serialized = serializer.serialize event, String

        lazy = LazyObject.new serialized, serializer
        
        lazy.serialized_object.should == serialized
        lazy.serializer.should == serializer
        lazy.type.should == TestEvent
        
        expect(lazy.deserialized?).to be_false

        deserialized_a = lazy.deserialized
        deserialized_b = lazy.deserialized
        
        deserialized_a.should be(deserialized_b)
        deserialized_a.should == event
        deserialized_b.should == event
        
        expect(lazy.deserialized?).to be_true
      end
      
    end
  end
end
