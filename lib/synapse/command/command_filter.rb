module Synapse
  module Command
    # Represents a mechanism for validating or modifying commands before they are dispatched on
    # the command bus. This filtering is done very early in the dispatch process, before a unit of
    # work is created for the dispatch.
    #
    # @abstract
    class CommandFilter
      # Called when a command is preparing to be dispatched on the command bus
      #
      # @abstract
      # @param [CommandMessage] command
      # @return [CommandMessage] The command to dispatch on the bus
      def filter(command); end
    end
  end
end
