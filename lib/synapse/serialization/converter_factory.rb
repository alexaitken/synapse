module Synapse
  module Serialization
    # Represents a mechanism for storing and retrieving converters capable of converting content
    # of one type to another type, for the purpose of serialization and upcasting.
    class ConverterFactory
      # @return [Set<Converter>]
      attr_reader :converters

      # @return [undefined]
      def initialize
        @converters = Set.new
      end

      # Adds the given converter to this converter factory
      #
      # @param [Converter] converter
      # @return [undefined]
      def register(converter)
        @converters.add converter
      end

      # Convenience method for converting a given serialized object to the given target type
      #
      # @param [SerializedObject] serialized_object
      # @param [Class] target_type
      # @return [SerializedObject]
      def convert(serialized_object, target_type)
        converter = converter serialized_object.content_type, target_type
        converter.convert serialized_object
      end

      # Returns a converter that is capable of converting content of the given source type to
      # the given target type, if one exists.
      #
      # @raise [ConversionError] If no converter is capable of performing the conversion
      # @param [Class] source_type
      # @param [Class] target_type
      # @return [Converter]
      def converter(source_type, target_type)
        if source_type == target_type
          return IdentityConverter.new source_type
        end

        @converters.each do |converter|
          return converter if converter.source_type == source_type &&
            converter.target_type == target_type
        end

        raise ConversionError, 'No converter capable of [%s] -> [%s]' % [source_type, target_type]
      end

      # Returns true if this factory contains a converter capable of converting content from the
      # given source type to the given target type.
      #
      # @param [Class] source_type
      # @param [Class] target_type
      # @return [Boolean]
      def has_converter?(source_type, target_type)
        if source_type == target_type
          return true
        end

        @converters.any? do |converter|
          converter.source_type == source_type && converter.target_type == target_type
        end
      end
    end # ConverterFactory
  end # Serialization
end
