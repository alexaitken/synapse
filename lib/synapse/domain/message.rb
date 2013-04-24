module Synapse
  module Domain
    # Represents the occurance of an event in the application that may be of some importance
    # to another component of the application. It contains the relevant data for other
    # components to act upon.
    class EventMessage < Message
      # @return [Time] The timestamp of when the event was reported
      attr_accessor :timestamp

      def initialize
        super
        @timestamp ||= Time.now
      end
    end

    # Message that contains a domain event as a payload that represents a state change in the domain.
    #
    # In contrast to a regular event message, this type of message contains the identifier of the
    # aggregate that reported it. It also contains a sequence number that allows the messages to be placed
    # in the order they were reported.
    class DomainEventMessage < EventMessage
      # @return [Object] The identifier of the aggregate that reported the event
      attr_accessor :aggregate_id

      # @return [Integer] The sequence number of the event in the order of generation
      attr_accessor :sequence_number
    end
  end
end
