module Synapse
  module Command
    # Mixin for an object capable of handling commands
    #
    # Consider using the command handler mixin that uses message wiring.
    module CommandHandler
      # Handles the given command
      #
      # @param [CommandMessage] command
      # @param [UnitOfWork] current_unit Current unit of work
      # @return [Object] The result of handling the given command
      def handle(command, current_unit); end
    end
  end
end
