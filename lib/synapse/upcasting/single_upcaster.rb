module Synapse
  module Upcasting
    # Specialized upcaster mixin for an upcaster that upcasts a serialized object into a single,
    # newer serialized object.
    #
    # This mixin is not suitable if an upcaster needs to upcast a  serialized object into multiple
    # newer serialized objects, or when the output representation type is not the same as the
    # expected representation type.
    module SingleUpcaster
      extend ActiveSupport::Concern
      include Upcaster

      # @param [SerialiedObject] intermediate
      # @param [Array<SerializedType>] expected_types
      # @param [UpcastingContext] upcast_context
      # @return [Array<SerializedObject>]
      def upcast(intermediate, expected_types, upcast_context)
        upcast_content = perform_upcast(intermediate, upcast_context)
        upcast_objects = Array.new

        unless upcast_content
          return upcast_objects
        end

        upcast_objects << Serialization::SerializedObject.new(upcast_content, expected_content_type, expected_types.at(0))
        upcast_objects
      end

      # @param [SerializedType] serialized_type
      # @return [Array<SerializedType>]
      def upcast_type(serialized_type)
        upcast_type = perform_upcast_type(serialized_type)
        upcast_types = Array.new

        unless upcast_type
          return upcast_types
        end

        upcast_types << upcast_type
        upcast_types
      end

    protected

      # @abstract
      # @param [SerializedObject] intermediate
      # @param [UpcastingContext] upcast_context
      # @return [Object] If nil is returned, the serialized object will be dropped
      def perform_upcast(intermediate, upcast_context); end

      # @abstract
      # @param [SerializedType] serialized_type
      # @return [SerializedType] If nil is returned, the serialized object will be dropped
      def perform_upcast_type(serialized_type); end
    end
  end
end
