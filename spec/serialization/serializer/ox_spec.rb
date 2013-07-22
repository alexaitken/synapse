require 'spec_helper'
require 'serialization/fixtures'

module Synapse
  module Serialization

    describe OxSerializer, ox: true do
      before do
        @serializer = OxSerializer.new ConverterFactory.new
      end

      it 'supports serializing and deserializing content' do
        event = TestEvent.new 'derp', 'herp'

        serialized_obj = @serializer.serialize event, String
        deserialized = @serializer.deserialize serialized_obj

        deserialized.should == event
      end

      it 'supports converting content to/from the native type' do
        type = SerializedType.new 'String', nil

        @serializer.type_for(String).should == type
        @serializer.class_for(type).should == String

        expect {
          @serializer.class_for(SerializedType.new('NonExistentClass', nil))
        }.to raise_error(UnknownSerializedTypeError)
      end
    end

  end
end
