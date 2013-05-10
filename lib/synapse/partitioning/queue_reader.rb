module Synapse
  module Partitioning
    # Represents a mechanism for taking messages off a queue and handling the acknowledgement
    # or rejection of each message
    #
    # @abstract
    class QueueReader
      # Subscribes the given handler to the queue
      #
      # Depending on the implementation, this method may or may not return immediately. It should
      # be assumed that the method will block until a message is received and then will go back
      # to blocking after the given callback is invoked.
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
