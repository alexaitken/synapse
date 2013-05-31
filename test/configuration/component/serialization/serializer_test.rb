require 'test_helper'

module Synapse
  module Configuration
    class SerializerDefinitionBuilderTest < Test::Unit::TestCase
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with an alternate converter factory' do
        @builder.converter_factory :alt_converter_factory
        @builder.serializer do
          use_converter_factory :alt_converter_factory
        end

        serializer = @container.resolve :serializer
        converter_factory = @container.resolve :alt_converter_factory
        assert_same converter_factory, serializer.converter_factory
      end

      should 'build with AttributeSerializer' do
        @builder.converter_factory
        @builder.serializer do
          use_attribute
        end

        serializer = @container.resolve :serializer
        assert serializer.is_a? Serialization::AttributeSerializer
      end

      should 'build with MarshalSerializer' do
        @builder.converter_factory
        @builder.serializer do
          use_marshal
        end

        serializer = @container.resolve :serializer
        assert serializer.is_a? Serialization::MarshalSerializer
      end

      should 'build with OxSerializer' do
        skip 'Ox not supported on JRuby' if defined? JRUBY_VERSION

        serialize_options = { :circular => true }

        @builder.converter_factory
        @builder.serializer do
          use_ox
          use_serialize_options serialize_options
        end

        serializer = @container.resolve :serializer
        assert serializer.is_a? Serialization::OxSerializer
        assert_equal serialize_options, serializer.serialize_options
      end

      should 'build with OjSerializer' do
        skip 'Oj not supported on JRuby' if defined? JRUBY_VERSION

        serialize_options = { :indent => 2, :circular => true }
        deserialize_options = { :symbol_keys => true }

        @builder.converter_factory
        @builder.serializer do
          use_oj
          use_serialize_options serialize_options
          use_deserialize_options deserialize_options
        end

        serializer = @container.resolve :serializer
        assert serializer.is_a? Serialization::OjSerializer
        assert_equal serialize_options, serializer.serialize_options
        assert_equal deserialize_options, serializer.deserialize_options
      end
    end
  end
end
