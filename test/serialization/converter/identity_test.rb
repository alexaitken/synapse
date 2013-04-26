require 'test_helper'

module Synapse
  module Serialization
    class IdentityConverterTest < Test::Unit::TestCase
      def test_conversion
        converter = IdentityConverter.new Object
        content = Hash.new

        assert_equal Object, converter.source_type
        assert_equal Object, converter.target_type
        assert content === converter.convert(content)
        assert content === converter.convert_content(content)
      end
    end
  end
end
