module Synapse
  module Configuration
    class ContainerBuilder
      # @yield [ConverterFactoryDefinitionBuilder]
      # @return [undefined]
      def converter_factory(&block)
        with_builder ConverterFactoryDefinitionBuilder, &block
      end
    end

    class ConverterFactoryDefinitionBuilder < ServiceDefinitionBuilder
      # @return [Symbol] Tag for any converters that should be registered
      attr_accessor :converter_tag

    protected

      # @return [undefined]
      def populate_defaults
        @id = :converter_factory
        @converter_tag = :converter

        with_factory do |container|
          factory = Serialization::ConverterFactory.new
          factory.tap do
            # Register any tagged converters with the newly created factory
            converters = container.fetch_tagged @converter_tag
            converters.each do |converter|
              factory.register converter
            end
          end
        end
      end
    end # ConverterFactoryDefinitionBuilder
  end # Configuration
end
