require 'spec_helper'

module Synapse
  module Configuration

    describe SerializerDefinitionBuilder do
      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      it 'builds with an alternate converter factory' do
        @builder.converter_factory :alt_converter_factory
        @builder.serializer do
          use_converter_factory :alt_converter_factory
        end

        serializer = @container.resolve :serializer
        converter_factory = @container.resolve :alt_converter_factory

        serializer.converter_factory.should be(converter_factory)
      end

      it 'builds with AttributeSerializer' do
        @builder.converter_factory
        @builder.serializer do
          use_attribute
        end

        serializer = @container.resolve :serializer
        serializer.should be_a(Serialization::AttributeSerializer)
      end

      it 'builds with MarshalSerializer' do
        @builder.converter_factory
        @builder.serializer do
          use_marshal
        end

        serializer = @container.resolve :serializer
        serializer.should be_a(Serialization::MarshalSerializer)
      end

      it 'builds with OxSerializer', ox: true do
        serialize_options = { circular: true }

        @builder.converter_factory
        @builder.serializer do
          use_ox
          use_serialize_options serialize_options
        end

        serializer = @container.resolve :serializer
        serializer.should be_a(Serialization::OxSerializer)
        serializer.serialize_options.should == serialize_options
      end

      it 'builds with OjSerializer', oj: true do
        serialize_options = { indent: 2, circular: true }
        deserialize_options = { symbol_keys: true }

        @builder.converter_factory
        @builder.serializer do
          use_oj
          use_serialize_options serialize_options
          use_deserialize_options deserialize_options
        end

        serializer = @container.resolve :serializer
        serializer.should be_a(Serialization::OjSerializer)
        serializer.serialize_options.should == serialize_options
        serializer.deserialize_options.should == deserialize_options
      end
    end

  end
end
