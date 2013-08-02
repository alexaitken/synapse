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

        lazy.should_not be_deserialized

        deserialized_a = lazy.deserialized
        deserialized_b = lazy.deserialized

        deserialized_a.should be(deserialized_b)
        deserialized_a.should == event
        deserialized_b.should == event

        lazy.should be_deserialized
      end

    end
  end
end
