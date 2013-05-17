module Synapse
  module Command
    # Represents an intent to change application state
    class CommandMessage < Message
      # @return [Class]
      def self.builder
        CommandMessageBuilder
      end

      # Creates a command message using the given command object
      #
      # If the given object is an command message, it will be returned unchanged.
      #
      # @param [Object] command
      # @return [CommandMessage]
      def self.as_message(command)
        unless command.is_a? CommandMessage
          command = self.build do |builder|
            builder.payload = command
          end
        end

        command
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
