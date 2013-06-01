require 'test_helper'
require 'upcasting/fixtures'

module Synapse
  module Upcasting
    class UpcasterChainTest < Test::Unit::TestCase

      should 'support multiple upcasters' do
        factory = Serialization::ConverterFactory.new

        chain = UpcasterChain.new factory
        chain.push TestTypeUpcaster.new
        chain.push TestSplitUpcaster.new
        chain.push TestPhaseOutUpcaster.new
        chain.converter_factory.register Serialization::JsonToObjectConverter.new

        content = Hash.new

        input = Serialization::SerializedObject.new(JSON.dump(content), String, Serialization::SerializedType.new('TestEvent', '1'))
        output = chain.upcast(input, nil)

        assert_equal 2, output.size
        assert_equal 'FooEvent', output[0].type.name
        assert_equal 'BarEvent', output[1].type.name
      end

    end
  end
end
