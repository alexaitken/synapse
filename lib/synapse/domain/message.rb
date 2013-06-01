module Synapse
  module Domain
    # Represents the occurance of an event in the application that may be of some importance
    # to another component of the application. It contains the relevant data for other
    # components to act upon.
    class EventMessage < Message
      # The timestamp of when the event was reported
      # @return [Time]
      attr_reader :timestamp

      # @param [String] id
      # @param [Hash] metadata
      # @param [Object] payload
      # @param [Time] timestamp
      # @return [undefined]
      def initialize(id, metadata, payload, timestamp)
        super id, metadata, payload
        @timestamp = timestamp
      end

      # @return [Class]
      def self.builder
        EventMessageBuilder
      end

    protected

      # @param [EventMessageBuilder] builder
      # @param [Hash] metadata
      # @return [undefined]
      def build_duplicate(builder, metadata)
        super
        builder.timestamp = @timestamp
      end
    end

    # Message that contains a domain event as a payload that represents a state change in the domain.
    #
    # In contrast to a regular event message, this type of message contains the identifier of the
    # aggregate that reported it. It also contains a sequence number that allows the messages to be placed
    # in the order they were reported.
    class DomainEventMessage < EventMessage
      # The identifier of the aggregate that reported the event
      # @return [Object]
      attr_reader :aggregate_id

      # The sequence number of the event in the order of generation
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

      # @return [Class]
      def self.builder
        DomainEventMessageBuilder
      end

    protected

      # @param [DomainEventMessageBuilder] builder
      # @param [Hash] metadata
      # @return [undefined]
      def build_duplicate(builder, metadata)
        super
        builder.aggregate_id = @aggregate_id
        builder.sequence_number = @sequence_number
      end
    end
  end
end
