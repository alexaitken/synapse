require 'spec_helper'

module Synapse
  module Serialization

    describe ConverterChain do
      it 'converts using a chain of converters' do
        converters = Array.new
        converters << ObjectToJsonConverter.new << JsonToObjectConverter.new

        chain = ConverterChain.new converters
        
        chain.source_type.should == Object
        chain.target_type.should == Object

        content = { foo: 0 }.stringify_keys

        type = SerializedType.new 'TestType', 1
        object = SerializedObject.new content, content.class, type

        converted = chain.convert object
        converted_content = chain.convert_content content
        
        converted.content.should == content
        converted_content.should == content
        converted.type.should == type
      end
    end

  end
end
