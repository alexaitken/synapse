module Synapse
  module Serialization
    # Represents a mechanism for serializing and deserializing objects
    class Serializer
      include AbstractType

      # @return [ConverterFactory]
      attr_writer :converter_factory

      # @return [RevisionResolver]
      attr_accessor :revision_resolver

      # @param [Object] object
      # @param [Class] representation_type
      # @return [SerializedObject]
      def serialize(object, representation_type)
        content = perform_serialize object
        content = convert content, native_content_type, representation_type
        type = type_for object.class

        SerializedObject.new content, representation_type, type
      end

      # @param [SerializedObject] serialized_object
      # @return [Object]
      def deserialize(serialized_object)
        content = convert serialized_object.content, serialized_object.content_type, native_content_type
        type = class_for serialized_object.type

        perform_deserialize content, type
      end

      # @param [Class] representation_type
      # @return [Boolean]
      def can_serialize_to?(representation_type)
        converter_factory.has_converter? native_content_type, representation_type
      end

      # @param [SerializedType] serialized_type
      # @return [Class]
      def class_for(serialized_type)
        name = serialized_type.name

        begin
          name.constantize
        rescue NameError
          raise UnknownSerializedTypeError, "Unknown serialized type {#{name}}"
        end
      end

      # @param [Class] type
      # @return [SerializedType]
      def type_for(type)
        if @revision_resolver
          SerializedType.new(type.name, @revision_resolver.revision_of(type))
        else
          SerializedType.new type.name
        end
      end

      # @return [ConverterFactory]
      def converter_factory
        @converter_factory ||= Serialization.converter_factory
      end

      protected

      # Serializes the given Ruby object
      #
      # @param [Object] content The original Ruby object to serialize
      # @return [Object] Should be in the native content type of the serializer
      abstract_method :perform_serialize

      # Deserializes the given serialized content into the given Ruby type
      #
      # @param [Object] content Should be in the native content type of the serializer
      # @param [Class] type The class type to be deserialized into
      # @return [Object] The deserialized object
      abstract_method :perform_deserialize

      # Returns the native content type that the serializer works with
      # @return [Class]
      abstract_method :native_content_type

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
