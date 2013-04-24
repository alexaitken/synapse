module Synapse
  module Serialization
    # @abstract
    class SerializedDomainEventData
      # @return [String]
      attr_reader :id

      # @return [SerializedObject]
      attr_reader :metadata

      # @return [SerializedObject]
      attr_reader :payload

      # @return [Time]
      attr_reader :timestamp

      # @return [Object]
      attr_reader :aggregate_id

      # @return [Integer]
      attr_reader :sequence_number
    end
  end
end
