module Synapse
  module Auditing
    # Represents a mechanism for auditing commands and the events produced by their execution
    class AuditLogger
      include AbstractType

      # Called when a command execution was finished successfully
      #
      # @param [CommandMessage] command
      # @param [Object] return_value
      # @param [Array] events
      # @return [undefined]
      abstract_method :on_success

      # Called when a command execution results in an exception being raised
      #
      # The list of events may not be empty; in this case, some events could have been published
      # to the event bus and/or appended to the event store.
      #
      # @param [CommandMessage] command
      # @param [Exception] exception
      # @param [Array] events
      # @return [undefined]
      abstract_method :on_failure
    end # AuditLogger
  end # Auditing
end
