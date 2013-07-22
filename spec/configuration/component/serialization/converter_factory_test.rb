require 'test_helper'

module Synapse
  module Configuration
    describe ConverterFactoryDefinitionBuilder do
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with sensible defaults' do
        @builder.converter_factory

        factory = @container.resolve :converter_factory
        assert factory.is_a? Serialization::ConverterFactory
      end

      should 'build and register tagged converters' do
        @builder.definition :json2object_converter do
          tag :converter, :alt_converter
          use_factory do
            Serialization::JsonToObjectConverter.new
          end
        end
        @builder.definition :json2object_alt_converter do
          tag :alt_converter
          use_factory do
            Serialization::JsonToObjectConverter.new
          end
        end

        # Defaults
        @builder.converter_factory

        factory = @container.resolve :converter_factory
        factory.converters.first.is_a? Serialization::JsonToObjectConverter

        # Customized
        @builder.converter_factory :alt_factory do
          use_converter_tag :alt_converter
        end

        factory = @container.resolve :alt_factory
        factory.converters.first.is_a? Serialization::JsonToObjectConverter
      end
    end
  end
end
