module Synapse
  module Upcasting
    class UpcasterChain
      attr_writer :converter_factory
      attr_reader :upcasters

      def initialize
        @upcasters = Array.new
      end

      # Appends the given upcaster to the end of this upcaster chain
      #
      # @param [Upcaster] upcaster
      # @return [undefined]
      def <<(upcaster)
        @upcasters << upcaster
      end

      # @param [SerializedObject] serialized_object
      # @param [UpcastingContext] upcast_context
      # @return [Array<SerializedObject>]
      def upcast(serialized_object, upcast_context)
        serialized_objects = Array.new
        serialized_objects << serialized_object

        @upcasters.each do |upcaster|
          serialized_objects = upcast_objects(upcaster, serialized_objects, upcast_context)
        end

        serialized_objects
      end

      # @return [ConverterFactory]
      def converter_factory
        @converter_factory ||= Serialization::ConverterFactory.new
      end

    protected

      # @param [Upcaster] upcaster
      # @param [SerializedObject] representation
      # @param [Array<SerializedType>] expected_types
      # @param [UpcastingContent] upcast_context
      # @return [Array<SerializedObject>]
      def perform_upcast(upcaster, representation, expected_types, upcast_context)
        upcaster.upcast(representation, expected_types, upcast_context)
      end

    private

      # @param [Upcaster] upcaster
      # @param [Array<SerializedObject>] serialized_objects
      # @param [UpcastingContext] upcast_context
      # @return [Array<SerializedObject>]
      def upcast_objects(upcaster, serialized_objects, upcast_context)
        upcast_objects = Array.new

        serialized_objects.each do |serialized_object|
          serialized_type = serialized_object.type

          if upcaster.can_upcast? serialized_type
            serialized_object = ensure_correct_type(serialized_object, upcaster.expected_content_type)
            expected_types = upcaster.upcast_type(serialized_type)

            upcast_objects.concat(perform_upcast(upcaster, serialized_object, expected_types, upcast_context))
          else
            upcast_objects << serialized_object
          end
        end

        upcast_objects
      end

      # @param [SerializedObject] serialized_object
      # @param [Class] expected_type
      # @return [SerializedObject]
      def ensure_correct_type(serialized_object, expected_type)
        converter_factory.converter(serialized_object.content_type, expected_type).convert(serialized_object)
      end
    end
  end
end
