module Synapse
  module Event
    # Builder that is used to easily create and populate event messages
    # @see EventMessage
    class EventMessageBuilder < MessageBuilder
      # @return [EventMessage]
      def build
        EventMessage.new id, metadata, payload, timestamp
      end
    end # EventMessageBuilder
  end # Event
end
