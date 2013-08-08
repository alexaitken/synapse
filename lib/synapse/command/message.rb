module Synapse
  module Command
    # @see CommandMessageBuilder
    class CommandMessage < Message
      # @return [Class]
      def self.builder
        CommandMessageBuilder
      end
    end # CommandMessage
  end # Command
end
