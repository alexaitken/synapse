module Synapse
  module Serialization
    # Implementation of a serializer that uses the hashing features of ActiveModel and Virtus
    #
    # If the object being serialized or deserialized is a hash, it will be untouched
    #
    # Objects being serialized by this implementation must meet the following requirements:
    # * Respond to #attributes and #attributes=
    # * #attributes= must work without the deserializer calling #initialize
    #
    # If either one of these are not met, the serializer may fail instantly or the deserialized
    # object could be put in a bad state
    class AttributeSerializer < Serializer
      # This serializer doesn't provide any configuration options

    protected

      # @param [Object] content
      # @return [Object]
      def perform_serialize(content)
        if content.is_a? Hash
          content
        else
          content.attributes
        end
      end

      # @param [Object] content
      # @param [Class] type
      # @return [Object]
      def perform_deserialize(content, type)
        if Hash == type
          content
        else
          # Allocate the target object but don't call #initialize
          object = type.allocate
          object.attributes = content
          object
        end
      end

      # @return [Class]
      def native_content_type
        Hash
      end
    end # AttributeSerializer
  end # Serialization
end
