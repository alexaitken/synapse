module Synapse
  module Command
    # Implementation of a command callback that does nothing
    class VoidCallback < CommandCallback
      # @param [Object] result The result from the command handler
      # @return [undefined]
      def on_success(result); end

      # @param [Exception] exception The cause of the failure
      # @return [undefined]
      def on_failure(exception); end
    end # VoidCallback
  end # Command
end
