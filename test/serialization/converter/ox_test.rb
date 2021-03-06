require 'test_helper'

module Synapse
  module Serialization
    class OxDocumentToXmlConverterTest < Test::Unit::TestCase
      def setup
        omit 'Ox not supported on JRuby' if defined? JRUBY_VERSION
      end

      should 'convert an Ox document to an XML string' do
        converter = OxDocumentToXmlConverter.new

        assert_equal Ox::Document, converter.source_type
        assert_equal String, converter.target_type

        input = Ox::Document.new
        output = converter.convert_content input

        assert_equal String, output.class
      end
    end

    class XmlToOxDocumentConverterTest < Test::Unit::TestCase
      def setup
        omit 'Ox not supported on JRuby' if defined? JRUBY_VERSION
      end

      should 'convert an XML string to an Ox document' do
        converter = XmlToOxDocumentConverter.new

        assert_equal String, converter.source_type
        assert_equal Ox::Document, converter.target_type

        output = converter.convert_content '<?xml?>'

        assert_equal Ox::Document, output.class
      end
    end
  end
end
