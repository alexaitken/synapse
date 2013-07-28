module Synapse
  module Command
    class AsynchronousCommandBus < SimpleCommandBus
      # @param [UnitOfWorkFactory] unit_factory
      # @param [ExecutorService] executor
      # @return [undefined]
      def initialize(unit_factory, executor)
        super unit_factory
        @executor = executor
      end

      # Dispatches the given command asynchronously and notifies the given callback after the
      # command has been dispatched
      #
      # @api public
      # @param [CommandMessage] command
      # @param [CommandCallback] callback
      # @return [undefined]
      def dispatch_with_callback(command, callback)
        @executor.execute do
          super command, callback
        end
      end

      # Shuts down the executor backing this command bus
      #
      # After this operation, no new commands will be accepted by this command bus. The calling
      # thread will be blocked for up to 60 seconds while waiting for the remaining commands
      # to be dispatched.
      #
      # @api public
      # @return [undefined]
      def shutdown
        @executor.shutdown
        @executor.await_termination 60
      end
    end # AsynchronousCommandBus
  end # Command
end
