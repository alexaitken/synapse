module Synapse
  module Serialization
    # Provides a generic lazy deserializing object
    class LazyObject
      # @return [SerializedObject]
      attr_reader :serialized_object

      # @return [Serializer]
      attr_reader :serializer

      # @return [Class]
      attr_reader :type

      # @param [SerializedObject] serialized_object
      # @param [Serializer] serializer
      # @return [undefined]
      def initialize(serialized_object, serializer)
        @serialized_object = serialized_object
        @serializer = serializer
        @type = serializer.class_for serialized_object.type
      end

      # Returns the deserialized version of the contained serialized object
      # @return [Object]
      def deserialized
        @deserialized ||= @serializer.deserialize @serialized_object
      end

      # Returns true if this object has been deserialized already
      # @return [Boolean]
      def deserialized?
        !!@deserialized
      end
    end
  end
end
