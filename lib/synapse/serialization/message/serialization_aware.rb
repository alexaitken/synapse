module Synapse
  module Serialization
    # Contract for message implementations that are aware of the serialization component and
    # can provide optimization for the serialization process
    module SerializationAware
      include AbstractType

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      abstract_method :serialize_metadata

      # @param [Serializer] serializer
      # @param [Class] expected_type
      # @return [SerializedObject]
      abstract_method :serialize_payload
    end # SerializationAware
  end # Serialization
end

