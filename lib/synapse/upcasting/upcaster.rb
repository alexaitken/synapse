module Synapse
  module Upcasting
    # Represents a mechanism for converting deprecated serialized objects into the current
    # format used by the application. If the serializer itself is not able to cope with the changed
    # formats, an upcaster provides flexibility for more complex structural transformations.
    #
    # Upcasters work on intermediate representations of the object to upcast. In most cases, this
    # representation is an object structure of some kind. The serializer is responsible for
    # converting the intermediate representation form to one that is compatible with the upcaster.
    #
    # For performance reasons, it is advisable to ensure that all upcasters in the same chain use
    # the same intermediate representation type.
    #
    # @abstract
    class Upcaster
      # @return [Class]
      class_attribute :expected_content_type

      # @param [Class] type
      # @return [undefined]
      def self.expects_content_type(type)
        self.expected_content_type = type
      end

      # Returns true if this upcaster is capable of upcasting the given type
      #
      # @abstract
      # @param [SerializedType] serialized_type
      # @return [Boolean]
      def can_upcast?(serialized_type)
        raise NotImplementedError
      end

      # Upcasts a given serialized object to zero or more upcast objects
      #
      # The types of the upcast objects should match the same length and order of the given array
      # of upcast types.
      #
      # @abstract
      # @param [SerialiedObject] intermediate
      # @param [Array<SerializedType>] expected_types
      # @param [UpcastingContext] upcast_context
      # @return [Array<SerializedObject>]
      def upcast(intermediate, expected_types, upcast_context)
        raise NotImplementedError
      end

      # Upcasts a given serialized type to zero or more upcast types
      #
      # @abstract
      # @param [SerializedType] serialized_type
      # @return [Array<SerializedType>]
      def upcast_type(serialized_type)
        raise NotImplementedError
      end
    end # Upcaster
  end # Upcasting
end
