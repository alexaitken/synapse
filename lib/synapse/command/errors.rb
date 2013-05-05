module Synapse
  module Command
    # Raised when an error is raised during the handling of a command
    class CommandExecutionError < SynapseError
      # @return [Exception]
      attr_reader :cause

      # @param [Exception] cause
      # @return [undefined]
      def initialize(cause)
        @cause = cause
        set_backtrace cause.backtrace
      end

      # @return [String]
      def inspect
        @cause.inspect
      end
    end

    # Raised when a command is refused because of structural validation errors
    class CommandValidationError < NonTransientError; end

    # Raised when a dispatched command has no handler subscribed to it
    class NoHandlerError < NonTransientError; end
  end
end
