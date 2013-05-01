module Synapse
  module Command
    # Raised when an error is raised during the handling of a command
    class CommandExecutionError < SynapseError
      attr_reader :cause

      def initialize(cause)
        @cause = cause
        set_backtrace cause.backtrace
      end
    end

    # Raised when a dispatched command has no handler subscribed to it
    class NoHandlerError < NonTransientError; end
  end
end