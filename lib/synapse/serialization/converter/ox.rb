require 'ox'

module Synapse
  module Serialization
    # Converter that converts an Ox document into an XML string
    class OxDocumentToXmlConverter
      include Converter

      converts Ox::Document, String

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        Ox.dump original, @options
      end
    end # OxDocumentToXmlConverter

    # Converter that converts an XML string into an Ox document
    class XmlToOxDocumentConverter
      include Converter

      converts String, Ox::Document

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        Ox.load original, @options
      end
    end # XmlToOxDocumentConverter
  end # Serialization
end
