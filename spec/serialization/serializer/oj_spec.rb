require 'spec_helper'
require 'serialization/fixtures'

module Synapse
  module Serialization

    describe OjSerializer, oj: true do
      it 'supports serializing and deserializing content' do
        serializer = OjSerializer.new ConverterFactory.new
        event = TestEvent.new 'derp', 'herp'

        serialized_obj = serializer.serialize event, String
        deserialized = serializer.deserialize serialized_obj

        deserialized.should == event
      end
    end

  end
end
