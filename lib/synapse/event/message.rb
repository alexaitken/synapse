module Synapse
  module Event
    # @see EventMessageBuilder
    class EventMessage < Message
      # @return [Class]
      def self.builder
        EventMessageBuilder
      end
    end # EventMessage
  end # Event
end
