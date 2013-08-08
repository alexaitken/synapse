module Synapse
  module Command
    # Callback that is notified of the outcome of the dispatch of a command
    class CommandCallback
      include AbstractType

      # Called when a dispatch is successful
      #
      # @param [Object] result The result from the command handler
      # @return [undefined]
      abstract_method :on_success

      # Called when a dispatch fails due to an exception
      #
      # @param [Exception] exception The cause of the failure
      # @return [undefined]
      abstract_method :on_failure
    end # CommandCallback
  end # Command
end
