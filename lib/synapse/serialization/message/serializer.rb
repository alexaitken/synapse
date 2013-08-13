module Synapse
  module Serialization
    # Serializer that provides convenience methods for serializing messages and adds support
    # for optimizing the serialization process
    class MessageSerializer
      extend Forwardable

      # @param [Serializer] serializer
      # @return [undefined]
      def initialize(serializer)
        @serializer = serializer
      end

      # Returns the serialized metadata for the given message in the expected type, optimizing
      # the serialization, if possible
      #
      # @param [Message] message
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_metadata(message, expected_type)
        if message.respond_to? :serialize_metadata
          message.serialize_metadata @serializer, expected_type
        else
          serialize message.metadata, expected_type
        end
      end

      # Returns the serialized payload for the given message in the expected type, optimizing
      # the serialization, if possible
      #
      # @param [Message] message
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_payload(message, expected_type)
        if message.respond_to? :serialize_payload
          message.serialize_payload @serializer, expected_type
        else
          serialize message.payload, expected_type
        end
      end

      # Delegators for regular serializer methods
      def_delegators :@serializer, :converter_factory, :serialize, :deserialize,
        :can_serialize_to?, :class_for, :type_for
    end # MessageSerializer
  end # Serialization
end

