module Synapse
  module Command
    # Represents an intent to change application state
    class CommandMessage < Message
      # @return [Class]
      def self.builder
        CommandMessageBuilder
      end
    end

    # Message builder capable of producing CommandMessage instances
    class CommandMessageBuilder < MessageBuilder
      # @return [CommandMessage]
      def build
        CommandMessage.new @id, @metadata, @payload
      end
    end
  end
end
