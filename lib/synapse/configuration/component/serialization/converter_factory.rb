module Synapse
  module Configuration
    # Definition builder used to create a converter factory
    #
    # @example The minimum possible effort to build a converter factory
    #   converter_factory
    #
    # @example Create a converter factory using a different identifier and different converter tag
    #   converter_factory :alt_converter_factory do
    #     use_converter_tag :alt_converter
    #   end
    #
    # @example Register several converters that will be picked up by a converter factory
    #   factory :xml2ox_converter, :tag => :converter do
    #     Serialization::XmlToOxDocumentConverter.new
    #   end
    #
    #   factory :ox2xml_converter, :tag => :converter do
    #     Serialization::OxDocumentToXmlConverter.new
    #   end
    class ConverterFactoryDefinitionBuilder < DefinitionBuilder
      # Changes the tag to use to automatically register converters
      #
      # @param [Symbol] converter_tag
      # @return [undefined]
      def use_converter_tag(converter_tag)
        @converter_tag = converter_tag
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :converter_factory

        use_converter_tag :converter

        use_factory do
          converter_factory = Serialization::ConverterFactory.new
          
          with_tagged @converter_tag do |converter|
            converter_factory.register converter
          end

          converter_factory
        end
      end
    end # ConverterFactoryDefinitionBuilder
  end # Configuration
end
