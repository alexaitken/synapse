module Synapse
  module Serialization
    # Implementation of an event message that can be lazily deserialized
    class SerializedEventMessage < SerializedMessage
      # @return [Time] The timestamp of when the event was reported
      attr_accessor :timestamp

    protected

      # @param [SerializedEventMessage] message
      # @param [Hash] metadata
      # @return [undefined]
      def populate_duplicate(message, metadata)
        super
        message.timestamp = @timestamp
      end
    end

    # Implementation of a domain event message that can be lazily deserialized
    class SerializedDomainEventMessage < SerializedEventMessage
      # @return [Object] The identifier of the aggregate that reported the event
      attr_accessor :aggregate_id

      # @return [Integer] The sequence number of the event in the order of generation
      attr_accessor :sequence_number

    protected

      # @param [SerializedDomainEventMessage] message
      # @param [Hash] metadata
      # @return [undefined]
      def populate_duplicate(message, metadata)
        super
        message.aggregate_id = @aggregate_id
        message.sequence_number = @sequence_number
      end
    end
  end
end
