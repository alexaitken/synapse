module Synapse
  module Serialization
    # Represents a mechanism for serializing and deserializing objects
    # @abstract
    class Serializer
      # @return [ConverterFactory]
      attr_reader :converter_factory

      # @return [RevisionResolver]
      attr_accessor :revision_resolver

      # @param [ConverterFactory] converter_factory
      # @return [undefined]
      def initialize(converter_factory)
        @converter_factory = converter_factory
      end

      # @param [Object] object
      # @param [Class] representation_type
      # @return [SerializedObject]
      def serialize(object, representation_type)
        content = perform_serialize(object)
        content = convert(content, native_content_type, representation_type)
        type = type_for(object.class)

        SerializedObject.new(content, representation_type, type)
      end

      # @param [SerializedObject] serialized_object
      # @return [Object]
      def deserialize(serialized_object)
        content = convert(serialized_object.content, serialized_object.content_type, native_content_type)
        type = class_for(serialized_object.type)

        perform_deserialize(content, type)
      end

      # @param [Class] representation_type
      # @return [Boolean]
      def can_serialize_to?(representation_type)
        converter_factory.has_converter?(native_content_type, representation_type)
      end

      # @param [SerializedType] serialized_type
      # @return [Class]
      def class_for(serialized_type)
        begin
          serialized_type.name.constantize
        rescue
          raise UnknownSerializedTypeError, 'Unknown serialized type %s' % serialized_type.name
        end
      end

      # @param [Class] type
      # @return [SerializedType]
      def type_for(type)
        if @revision_resolver
          SerializedType.new(type.to_s, @revision_resolver.revision_of(type))
        else
          SerializedType.new(type.to_s)
        end
      end

    protected

      # Serializes the given Ruby object
      #
      # @abstract
      # @param [Object] content The original Ruby object to serialize
      # @return [Object] Should be in the native content type of the serializer
      def perform_serialize(content); end

      # Deserializes the given serialized content into the given Ruby type
      #
      # @abstract
      # @param [Object] content Should be in the native content type of the serializer
      # @param [Class] type The class type to be deserialized into
      # @return [Object] The deserialized object
      def perform_deserialize(content, type); end

      # Returns the native content type that the serializer works with
      #
      # @abstract
      # @return [Class]
      def native_content_type; end

    private

      # Converts the given content from the given source type to the given target type
      #
      # @param [Object] original
      # @param [Class] source_type
      # @param [Class] target_type
      # @return [Object]
      def convert(original, source_type, target_type)
        converter_factory.converter(source_type, target_type).convert_content(original)
      end
    end # Serializer
  end # Serialization
end
