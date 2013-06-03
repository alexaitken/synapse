require 'test_helper'

module Synapse
  module Serialization
    class JsonToObjectConverterTest < Test::Unit::TestCase
      should 'convert content from a JSON string to a Ruby data structure' do
        converter = JsonToObjectConverter.new

        assert_equal String, converter.source_type
        assert_equal Object, converter.target_type

        output = converter.convert_content '{}'

        assert_equal Hash, output.class
      end
    end

    class ObjectToJsonConverterTest < Test::Unit::TestCase
      should 'convert a Ruby data structure to a JSON string' do
        converter = ObjectToJsonConverter.new

        assert_equal Object, converter.source_type
        assert_equal String, converter.target_type

        output = converter.convert_content Hash.new

        assert_equal String, output.class
      end
    end
  end
end
