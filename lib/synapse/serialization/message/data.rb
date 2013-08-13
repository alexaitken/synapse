module Synapse
  module Serialization
    # Describes the properties that a serialized domain event should have
    class SerializedDomainEventData
      include AbstractType

      # @return [String] Identifier of the serialized event
      abstract_method :id

      # @return [SerializedObject] Serialized metadata of the serialized event
      abstract_method :metadata

      # @return [SerializedObject] Serialized payload of the serialized event
      abstract_method :payload

      # @return [Time] Timestamp of the serialized event
      abstract_method :timestamp

      # @return [Object] Identifier of the aggregate that the event was applied to
      abstract_method :aggregate_id

      # @return [Integer] Sequence number of the event in the aggregate
      abstract_method :sequence_number
    end # SerializedDomainEventData
  end # Serialization
end

