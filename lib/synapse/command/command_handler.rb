module Synapse
  module Command
    # Mixin for an object capable of handling commands
    module CommandHandler
      include AbstractType

      # Handles the given command
      #
      # @param [CommandMessage] message
      # @param [Unit] current_unit
      # @return [Object]
      abstract_method :handle
    end # CommandHandler
  end # Command
end
