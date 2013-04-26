require 'test_helper'
require 'ox'

module Synapse
  module Serialization

    class ConverterFactoryTest < Test::Unit::TestCase

      def setup
        @factory = ConverterFactory.new
      end

      def test_identity
        assert @factory.has_converter?(String, String)
        assert @factory.converter(String, String).is_a?(IdentityConverter)
      end

      def test_converter
        refute @factory.has_converter?(Ox::Document, String)

        assert_raise ConversionError do
          @factory.converter(Ox::Document, String)
        end

        converter = OxDocumentToXmlConverter.new
        @factory << converter

        assert @factory.has_converter?(Ox::Document, String)
        assert_equal converter, @factory.converter(Ox::Document, String)
      end
    end

  end
end
