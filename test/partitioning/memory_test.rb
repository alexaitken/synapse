require 'test_helper'

module Synapse
  module Partitioning

    class MemoryQueueTest < Test::Unit::TestCase
      def test_queuing
        message = MessageBuilder.build

        queue = Queue.new

        reader = MemoryQueueReader.new queue, :test
        writer = MemoryQueueWriter.new queue

        count = 0

        Thread.new do
          reader.subscribe do |receipt|
            assert_equal message, receipt.packed
            assert_equal :test, receipt.queue_name

            count = count.next
          end
        end

        writer.put_message message, message
        writer.put_message message, message

        wait_until { count == 2 }
      end
    end

  end
end
