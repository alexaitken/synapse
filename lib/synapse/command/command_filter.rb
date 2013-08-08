module Synapse
  module Command
    # Represents a mechanism for validating or modifying commands before they are dispatched on
    # the command bus. This filtering is done very early in the dispatch process, before a unit of
    # work is created for the dispatch.
    class CommandFilter
      include AbstractType

      # Called when a command is preparing to be dispatched on the command bus
      #
      # @param [CommandMessage] command
      # @return [CommandMessage] The command to dispatch on the bus
      abstract_method :filter
    end # CommandFilter
  end # Command
end
