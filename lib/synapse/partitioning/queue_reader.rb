module Synapse
  module Partitioning
    # Retrieves messages from one or more queues, waiting if needed
    # @abstract
    class QueueReader
      # @return [undefined]
      def start; end

      # Subscribes the given handler to the queue
      #
      # @abstract
      # @yield [MessageReceipt] Receipt of the message taken off the queue
      # @return [undefined]
      def subscribe(&handler); end

      # Acknowledges the message, removing it from the original queue
      #
      # @param [MessageReceipt] receipt
      # @return [undefined]
      def ack_message(receipt); end

      # Attempts to notify the original queue that the message was not processed
      #
      # @param [MessageReceipt] receipt
      # @return [undefined]
      def nack_message(receipt); end
    end
  end
end
