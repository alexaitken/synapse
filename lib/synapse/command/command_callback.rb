module Synapse
  module Command
    # Callback that is notified of the outcome of the dispatch of a command
    # @abstract
    class CommandCallback
      # Called when a dispatch is successful
      #
      # @abstract
      # @param [Object] result The result from the command handler
      # @return [undefined]
      def on_success(result)
        raise NotImplementedError
      end

      # Called when a dispatch fails due to an exception
      #
      # @abstract
      # @param [Exception] exception The cause of the failure
      # @return [undefined]
      def on_failure(exception)
        raise NotImplementedError
      end
    end # CommandCallback
  end # Command
end
