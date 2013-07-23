begin
  require 'ox'
rescue LoadError
  warn 'Ensure that Ox is installed before using the Ox converter'
end

module Synapse
  module Serialization
    # Converter that converts an Ox document into an XML string
    class OxDocumentToXmlConverter
      include Converter

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        Ox.dump original, @options
      end

      # @return [Class]
      def source_type
        Ox::Document
      end

      # @return [Class]
      def target_type
        String
      end
    end # OxDocumentToXmlConverter

    # Converter that converts an XML string into an Ox document
    class XmlToOxDocumentConverter
      include Converter

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        Ox.load original, @options
      end

      # @return [Class]
      def source_type
        String
      end

      # @return [Class]
      def target_type
        Ox::Document
      end
    end # XmlToOxDocumentConverter
  end # Serialization
end
