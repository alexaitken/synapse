module Synapse
  module Serialization
    # Message builder capable of producing SerializedMessage instances
    class SerializedMessageBuilder
      # @return [String]
      attr_accessor :id

      # @return [LazyObject]
      attr_accessor :metadata

      # @return [LazyObject]
      attr_accessor :payload

      # @return [Time]
      attr_accessor :timestamp

      def self.build
        builder = self.new

        yield builder if block_given?

        builder.build
      end

      def build
        SerializedMessage.new @id, @metadata, @payload, @timestamp
      end
    end # SerializedMessageBuilder

    # Message builder capable of producing SerializedEventMessage instances
    class SerializedEventMessageBuilder < SerializedMessageBuilder
      # @return [SerializedEventMessage]
      def build
        SerializedEventMessage.new @id, @metadata, @payload, @timestamp
      end
    end # SerializedEventMessageBuilder

    # Message builder capable of producing SerializedDomainEventMessage instances
    class SerializedDomainEventMessageBuilder < SerializedEventMessageBuilder
      # @return [Object]
      attr_accessor :aggregate_id

      # @return [Integer]
      attr_accessor :sequence_number

      # @param [SerializedDomainEventData] data
      # @param [Serializer] serializer
      # @return [undefined]
      def from_data(data, serializer)
        @id = data.id
        @metadata ||= LazyObject.new data.metadata, serializer
        @payload ||= LazyObject.new data.payload, serializer
        @timestamp = data.timestamp
        @aggregate_id = data.aggregate_id
        @sequence_number = data.sequence_number
      end

      # @return [SerializedDomainEventMessage]
      def build
        SerializedDomainEventMessage.new @id, @metadata, @payload, @timestamp, @aggregate_id, @sequence_number
      end
    end # SerializedDomainEventMessageBuilder
  end # Serialization
end
