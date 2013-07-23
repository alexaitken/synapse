require 'spec_helper'
require 'upcasting/fixtures'

module Synapse
  module Upcasting

    describe UpcasterChain do
      it 'treats registered upcasters as an upcasting pipeline' do
        cf = Serialization::ConverterFactory.new
        cf.register Serialization::JsonToObjectConverter.new

        upcasters = [
          TestTypeUpcaster.new,
          TestSplitUpcaster.new,
          TestPhaseOutUpcaster.new
        ]

        chain = UpcasterChain.new cf, upcasters

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
