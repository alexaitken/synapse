module Synapse
  module Command
    # Callback that is notified of the outcome of the dispatch of a command
    class CommandCallback
      # Called when a dispatch is successful
      #
      # @param [Object] result The result from the command handler
      # @return [undefined]
      def on_success(result); end

      # Called when a dispatch fails due to an exception
      #
      # @param [Exception] exception The cause of the failure
      # @return [undefined]
      def on_failure(exception); end
    end
  end
end
