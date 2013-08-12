module Synapse
  module Command
    # Implementation of a command callback that does nothing
    class VoidCallback < CommandCallback
      # @return [undefined]
      def on_success(*)
        # This method is intentionally empty
      end

      # @return [undefined]
      def on_failure(*)
        # This method is intentionally empty
      end
    end # VoidCallback
  end # Command
end
