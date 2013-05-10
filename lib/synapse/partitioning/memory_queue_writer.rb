module Synapse
  module Partitioning
    # Queue writer that pushes message into an in-memory Ruby queue
    class MemoryQueueWriter < QueueWriter
      # @param [Queue] queue
      # @return [undefined]
      def initialize(queue)
        @queue = queue
      end

      # @param [Object] packed
      # @param [Message] unpacked
      # @return [undefined]
      def put_message(packed, unpacked)
        @queue.push packed
      end
    end
  end
end
