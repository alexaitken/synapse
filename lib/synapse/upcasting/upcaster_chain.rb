module Synapse
  module Upcasting
    class UpcasterChain
      # @param [ConverterFactory] converter_factory
      # @param [Array] upcasters
      # @return [undefined]
      def initialize(converter_factory, upcasters)
        @converter_factory = converter_factory
        @upcasters = upcasters
      end

      # @param [SerializedObject] serialized_object
      # @param [UpcastingContext] upcast_context
      # @return [Array]
      def upcast(serialized_object, upcast_context)
        serialized_objects = Array.new
        serialized_objects.push serialized_object

        @upcasters.each do |upcaster|
          serialized_objects = upcast_objects upcaster, serialized_objects, upcast_context
        end

        serialized_objects
      end

      protected

      # @param [Upcaster] upcaster
      # @param [SerializedObject] representation
      # @param [Array] expected_types
      # @param [UpcastingContent] upcast_context
      # @return [Array]
      def perform_upcast(upcaster, representation, expected_types, upcast_context)
        upcaster.upcast representation, expected_types, upcast_context
      end

      private

      # @param [Upcaster] upcaster
      # @param [Array] serialized_objects
      # @param [UpcastingContext] upcast_context
      # @return [Array]
      def upcast_objects(upcaster, serialized_objects, upcast_context)
        upcast_objects = Array.new

        serialized_objects.each do |serialized_object|
          serialized_type = serialized_object.type

          if upcaster.can_upcast? serialized_type
            serialized_object = @converter_factory.convert serialized_object, upcaster.expected_content_type
            expected_types = upcaster.upcast_type serialized_type

            upcast_objects.concat(perform_upcast(upcaster, serialized_object, expected_types, upcast_context))
          else
            upcast_objects.push serialized_object
          end
        end

        upcast_objects
      end
    end # UpcasterChain
  end # Upcasting
end
