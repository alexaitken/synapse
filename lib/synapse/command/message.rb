module Synapse
  module Command
    # Represents an intent to change application state
    class CommandMessage < Message
      # @return [Class]
      def self.builder
        CommandMessageBuilder
      end
    end # CommandMessage

    # Message builder capable of producing CommandMessage instances
    class CommandMessageBuilder < MessageBuilder
      # @return [CommandMessage]
      def build
        CommandMessage.new @id, @metadata, @payload, @timestamp
      end
    end # CommandMessageBuilder
  end # Command
end
