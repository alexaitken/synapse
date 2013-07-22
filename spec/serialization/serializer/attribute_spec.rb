require 'spec_helper'

module Synapse
  module Serialization

    describe AttributeSerializer do
      it 'supports serialization and deserialization of a hash' do
        converter_factory = ConverterFactory.new
        serializer = AttributeSerializer.new converter_factory

        content = {
          foo: 0
        }

        serialized_object = serializer.serialize(content, Hash)

        expect(serialized_object.content).to eql(content)
        expect(serializer.deserialize(serialized_object)).to eql(content)

        expect(serializer.can_serialize_to?(Hash)).to be_true
      end

      it 'supports serialization and deserialization of a compatible object' do
        converter_factory = ConverterFactory.new
        serializer = AttributeSerializer.new converter_factory

        content = SomeAttributeEvent.new 0

        attributes = {
          foo: 0
        }

        serialized_object = serializer.serialize(content, Hash)

        expect(serialized_object.content).to eql(attributes)
        expect(serializer.deserialize(serialized_object).attributes).to eql(attributes)
      end
    end

    class SomeAttributeEvent
      attr_accessor :attributes

      def initialize(some_value)
        @attributes = {
          foo: some_value
        }
      end
    end

  end
end
