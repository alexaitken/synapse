module Synapse
  module Auditing
    # Represents a mechanism for auditing commands and the events produced by their execution
    # @abstract
    class AuditLogger
      # Called when a command execution was finished successfully
      #
      # @abstract
      # @param [CommandMessage] command
      # @param [Object] return_value
      # @param [Array<EventMessage>] events
      # @return [undefined]
      def on_success(command, return_value, events); end

      # Called when a command execution results in an exception being raised
      #
      # The list of events may not be empty; in this case, some events could have been published
      # to the event bus and/or appended to the event store.
      #
      # @abstract
      # @param [CommandMessage] command
      # @param [Exception] exception
      # @param [Array<EventMessage>] events
      # @return [undefined]
      def on_failure(command, exception, events); end
    end
  end
end
