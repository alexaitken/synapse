require 'test_helper'
require 'upcasting/fixtures'

module Synapse
  module Upcasting
    class UpcasterChainTest < Test::Unit::TestCase

      def test_multiple_upcasters
        chain = UpcasterChain.new
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
