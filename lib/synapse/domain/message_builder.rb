module Synapse
  module Domain
    # Builder that is used to easily create and populate domain event messages
    #
    # @see DomainEventMessage
    # @api public
    class DomainEventMessageBuilder < Event::EventMessageBuilder
      # @return [Object]
      attr_accessor :aggregate_id

      # @return [Integer]
      attr_accessor :sequence_number

      # @return [DomainEventMessage]
      def build
        DomainEventMessage.new id, metadata, payload, timestamp, aggregate_id, sequence_number
      end
    end # DomainEventMessageBuilder
  end # Domain
end
