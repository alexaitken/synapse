module Synapse
  module Domain
    # Message builder capable of producing EventMessage instances
    class EventMessageBuilder < MessageBuilder
      # @return [EventMessage]
      def build
        EventMessage.new @id, @metadata, @payload, @timestamp
      end
    end

    # Message builder capable of producing DomainEventMessage instances
    class DomainEventMessageBuilder < EventMessageBuilder
      # @return [Object]
      attr_accessor :aggregate_id

      # @return [Integer]
      attr_accessor :sequence_number

      # @return [DomainEventMessage]
      def build
        DomainEventMessage.new @id, @metadata, @payload, @timestamp, @aggregate_id, @sequence_number
      end
    end # DomainEventMessageBuilder
  end # Domain
end
