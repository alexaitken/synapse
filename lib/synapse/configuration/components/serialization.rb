module Synapse
  module Configuration
    # Extension to container builder that adds a converter factory builder
    class ContainerBuilder
      # @yield [ConverterFactoryDefinitionBuilder]
      # @return [undefined]
      def converter_factory(&block)
        with_builder ConverterFactoryDefinitionBuilder, &block
      end
    end

    # Service definition builder that makes it easier to use a converter factory
    class ConverterFactoryDefinitionBuilder < ServiceDefinitionBuilder
      # @return [Symbol] Tag for any converters that should be registered
      attr_accessor :converter_tag

    protected

      # @return [undefined]
      def populate_defaults
        @id = :converter_factory
        @converter_tag = :converter

        with_factory do
          converter_factory = Serialization::ConverterFactory.new
          converter_factory.tap do
            register_converters converter_factory
          end
        end
      end

    private

      # @param [ConverterFactory] converter_factory
      # @return [undefined]
      def register_converters(converter_factory)
        converters = @container.fetch_tagged @converter_tag
        converters.each do |converter|
          converter_factory.register converter
        end
      end
    end # ConverterFactoryDefinitionBuilder
  end # Configuration
end
