module Synapse
  module Serialization
    # Contract for message implementations that are aware of the serialization component and
    # can provide optimization for the serialization process
    module SerializationAware
      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_metadata(serializer, expected_type)
        raise NotImplementedError
      end

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      def serialize_payload(serializer, expected_type)
        raise NotImplementedError
      end
    end # SerializationAware
  end # Serialization
end
