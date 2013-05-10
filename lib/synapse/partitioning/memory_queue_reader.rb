module Synapse
  module Partitioning
    # Queue reader that dequeues messages from an in-memory Ruby queue
    class MemoryQueueReader < QueueReader
      # @param [Queue] queue
      # @param [String] name Name of the queue being read from
      # @return [undefined]
      def initialize(queue, name)
        @queue = queue
        @name = name
      end

      # @yield [MessageReceipt] Receipt of the message taken off the queue
      # @return [undefined]
      def subscribe(&handler)
        loop do
          packed = @queue.pop

          receipt = MessageReceipt.new 0, packed, @name
          handler.call receipt
        end
      end

      # @param [MessageReceipt] receipt
      # @return [undefined]
      def nack_message(receipt)
        @queue.push receipt.packed
      end
    end
  end
end
