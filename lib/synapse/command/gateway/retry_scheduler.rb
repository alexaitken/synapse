module Synapse
  module Command
    # Represents a mechanism that decides whether or not to dispatch a command when previous
    # attempts resulted in an exception being raised.
    #
    # @abstract
    class RetryScheduler
      # Inspects the given command message that failed due to an exception
      #
      # The given list of failures contains exceptions that have occured each time the command
      # was dispatched by the command bus. It includes the most recent failure at the end of
      # the list.
      #
      # The return value of this method indicates whether or not the command has been scheduled
      # for a retry. If it has, the callback for the command should not be invoked. Otherwise,
      # the failure will be interpreted as terminal and the callback will be invoked with the
      # last recorded failure.
      #
      # @abstract
      # @param [CommandMessage] command
      # @param [Array] failures
      # @param [Proc] dispatcher
      # @return [Boolean]
      def schedule(command, failures, dispatcher)
        raise NotImplementedError
      end
    end # RetryScheduler
  end # Command
end
