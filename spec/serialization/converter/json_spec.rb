require 'spec_helper'

module Synapse
  module Serialization

    describe JsonToObjectConverter do
      it 'converts content from a JSON string to a Ruby data structure' do
        converter = JsonToObjectConverter.new

        converter.source_type.should == String
        converter.target_type.should == Object

        output = converter.convert_content '{}'

        output.class.should == Hash
      end
    end

    describe ObjectToJsonConverter do
      it 'converts a Ruby data structure to a JSON string' do
        converter = ObjectToJsonConverter.new

        converter.source_type.should == Object
        converter.target_type.should == String

        output = converter.convert_content Hash.new

        output.class.should == String
      end
    end

  end
end
