require 'test_helper'

module Synapse
  module Serialization
    
    class AttributeSerializerTest < Test::Unit::TestCase
      should 'support serialization and deserialization of a hash' do
        converter_factory = ConverterFactory.new
        serializer = AttributeSerializer.new converter_factory

        content = {
          foo: 0
        }

        serialized_object = serializer.serialize(content, Hash)
        assert_same content, serialized_object.content
        assert_same content, serializer.deserialize(serialized_object)

        assert serializer.can_serialize_to? Hash
      end

      should 'support serialization and deserialization of a compatible object' do
        converter_factory = ConverterFactory.new
        serializer = AttributeSerializer.new converter_factory

        content = SomeAttributeEvent.new 0

        attributes = {
          foo: 0
        }

        serialized_object = serializer.serialize(content, Hash)
        assert_equal attributes, serialized_object.content

        deserialized = serializer.deserialize serialized_object
        assert_equal attributes, deserialized.attributes
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
