require 'test_helper'

module Synapse
  module Serialization

    class ConverterChainTest < Test::Unit::TestCase
      should 'convert using a chain of converters' do
        converters = Array.new
        converters << ObjectToJsonConverter.new << JsonToObjectConverter.new

        chain = ConverterChain.new converters

        assert_equal Object, chain.source_type
        assert_equal Object, chain.target_type

        content = { foo: 0 }.stringify_keys

        type = SerializedType.new 'TestType', 1
        object = SerializedObject.new content, content.class, type

        converted = chain.convert object
        converted_content = chain.convert_content content

        assert_equal content, converted.content
        assert_equal content, converted_content
        assert_equal type, converted.type
      end
    end

  end
end
