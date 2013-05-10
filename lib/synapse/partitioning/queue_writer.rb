module Synapse
  module Partitioning
    # Represents a mechanism for writing packed messages to a queue
    # @abstract
    class QueueWriter
      # Enqueues the given message
      #
      # Depending on the implementation, this method may or may not block until the message has
      # been enqueued.
      #
      # @param [Object] packed
      # @param [Message] unpacked
      # @return [undefined]
      def put_message(packed, unpacked); end
    end
  end
end
