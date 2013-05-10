require 'test_helper'

module Synapse
  module Partitioning

    class MemoryQueueTest < Test::Unit::TestCase
      def test_queuing
        Thread.new do
          EventMachine.run
        end

        message = MessageBuilder.build

        queue = EventMachine::Queue.new

        reader = MemoryQueueReader.new queue, :test
        writer = MemoryQueueWriter.new queue

        counter = 0

        reader.subscribe do |packed|
          if counter == 0
            # Why not test NACK while we're here..
            # Unit tests? No, I write INTEGRATION tests.
            reader.nack_message packed
          end
          counter = counter.next
        end

        writer.put_message message, message
        writer.put_message message, message

        # No need to assert.. if the code is broken, I'll just punish myself with an infinite loop.
        until counter == 3
          sleep 0.1
        end

        EventMachine.stop
      end
    end

  end
end
