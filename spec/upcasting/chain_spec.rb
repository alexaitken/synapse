require 'spec_helper'
require 'upcasting/fixtures'

module Synapse
  module Upcasting
    
    describe UpcasterChain do
      it 'treats registered upcasters as an upcasting pipeline' do
        factory = Serialization::ConverterFactory.new

        chain = UpcasterChain.new factory
        chain.push TestTypeUpcaster.new
        chain.push TestSplitUpcaster.new
        chain.push TestPhaseOutUpcaster.new
        chain.converter_factory.register Serialization::JsonToObjectConverter.new

        content = Hash.new

        input = Serialization::SerializedObject.new(JSON.dump(content), String, Serialization::SerializedType.new('TestEvent', '1'))
        output = chain.upcast(input, nil)

        output.size.should == 2
        output[0].type.name.should == 'FooEvent'
        output[1].type.name.should == 'BarEvent'
      end
    end
    
  end
end
