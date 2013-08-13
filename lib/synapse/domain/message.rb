module Synapse
  module Domain
    # @see DomainEventMessageBuilder
    class DomainEventMessage < Event::EventMessage
      # @return [Class]
      def self.builder_type
        DomainEventMessageBuilder
      end

      # @return [Object]
      attr_reader :aggregate_id

      # @return [Integer]
      attr_reader :sequence_number

      # @param [String] id
      # @param [Hash] metadata
      # @param [Object] payload
      # @param [Time] timestamp
      # @param [Object] aggregate_id
      # @param [Integer] sequence_number
      # @return [undefined]
      def initialize(id, metadata, payload, timestamp, aggregate_id, sequence_number)
        super id, metadata, payload, timestamp

        @aggregate_id = aggregate_id
        @sequence_number = sequence_number
      end

      protected

      # @param [MessageBuilder] builder
      # @param [Hash] metadata
      # @return [undefined]
      def populate_duplicate(builder, metadata)
        super

        builder.aggregate_id = @aggregate_id
        builder.sequence_number = @sequence_number
      end
    end # DomainEventMessage
  end # Domain
end
