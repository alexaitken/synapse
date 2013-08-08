module Synapse
  module Command
    # Builder that is used to easily create and populate command messages
    # @see CommandMessage
    class CommandMessageBuilder < MessageBuilder
      # @return [CommandMessage]
      def build
        CommandMessage.new id, metadata, payload, timestamp
      end
    end # CommandMessageBuilder
  end # Command
end
