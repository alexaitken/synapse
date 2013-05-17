require 'test_helper'

module Synapse
  module Configuration
    class SerializerDefinitionBuilderTest < Test::Unit::TestCase
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      def test_alt_converter_factory
        @builder.converter_factory :alt_converter_factory
        @builder.serializer do
          use_converter_factory :alt_converter_factory
        end

        serializer = @container.resolve :serializer
        converter_factory = @container.resolve :alt_converter_factory
        assert_same converter_factory, serializer.converter_factory
      end

      def test_attribute
        @builder.converter_factory
        @builder.serializer do
          use_attribute
        end

        serializer = @container.resolve :serializer
        assert serializer.is_a? Serialization::AttributeSerializer
      end

      def test_marshal
        @builder.converter_factory
        @builder.serializer do
          use_marshal
        end

        serializer = @container.resolve :serializer
        assert serializer.is_a? Serialization::MarshalSerializer
      end
    end
  end
end
