module Synapse
  module Partitioning
    # Queue reader that dequeues messages from an in-memory EventMachine queue
    class MemoryQueueReader < QueueReader
      # @param [EventMachine::Queue] queue
      # @param [String] name Name of the queue being read from
      # @return [undefined]
      def initialize(queue, name)
        @queue = queue
        @name = name
      end

      # @yield [MessageReceipt] Receipt of the message taken off the queue
      # @return [undefined]
      def subscribe(&handler)
        # This will either yield on the next EventMachine reactor tick or it will sleep until
        # a new message is put into the queue
        callback = proc do |packed|
          receipt = MessageReceipt.new nil, packed, @name
          handler.call receipt

          @queue.pop callback
        end

        @queue.pop callback
      end

      # @param [MessageReceipt] receipt
      # @return [undefined]
      def nack_message(receipt)
        @queue.push receipt.packed
      end
    end
  end
end
