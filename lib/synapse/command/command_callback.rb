module Synapse
  module Command
    class CommandCallback
      # @param [Object] result
      # @return [undefined]
      def on_success(result); end

      # @param [Exception] exception
      # @return [undefined]
      def on_failure(exception); end
    end
  end
end
