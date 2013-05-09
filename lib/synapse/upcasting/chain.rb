module Synapse
  module Upcasting
    class UpcasterChain
      # @return [ConverterFactory]
      attr_accessor :converter_factory

      # @return [Array<Upcaster>]
      attr_accessor :upcasters

      # @param [ConverterFactory] converter_factory
      # @return [undefined]
      def initialize(converter_factory)
        @converter_factory = converter_factory
        @upcasters = Array.new
      end

      # Pushes the given upcaster onto the end of this upcaster chain
      #
      # @param [Upcaster] upcaster
      # @return [undefined]
      def push(upcaster)
        @upcasters.push upcaster
      end

      alias << push

      # @param [SerializedObject] serialized_object
      # @param [UpcastingContext] upcast_context
      # @return [Array<SerializedObject>]
      def upcast(serialized_object, upcast_context)
        serialized_objects = Array.new
        serialized_objects.push serialized_object

        @upcasters.each do |upcaster|
          serialized_objects = upcast_objects(upcaster, serialized_objects, upcast_context)
        end

        serialized_objects
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
            serialized_object = converter_factory.convert serialized_object, upcaster.expected_content_type
            expected_types = upcaster.upcast_type serialized_type

            upcast_objects.concat(perform_upcast(upcaster, serialized_object, expected_types, upcast_context))
          else
            upcast_objects.push serialized_object
          end
        end

        upcast_objects
      end
    end
  end
end
