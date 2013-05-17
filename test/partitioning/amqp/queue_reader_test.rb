require 'test_helper'

module Synapse
  module Partitioning
    module AMQP

      class AMQPQueueReaderTest < Test::Unit::TestCase
        def setup
          @queue = Object.new
          @queue_name = 'queue_partitioning'

          mock(@queue).name.any_times do
            @queue_name
          end

          @channel = Object.new
          @inbox = AMQPQueueReader.new @queue, @channel
        end

        def test_subscribe
          headers = OpenStruct.new delivery_tag: 123
          packed = 'packed'

          mock(@queue).subscribe(ack: true).returns do |options, proc|
            proc.call headers, packed
          end

          @inbox.subscribe do |receipt|
            assert_equal headers.delivery_tag, receipt.tag
            assert_equal packed, receipt.packed
            assert_equal @queue_name, receipt.queue_name
          end
        end

        def test_ack_message
          mock(@channel).acknowledge 123

          receipt = MessageReceipt.new 123, 'packed', @queue_name
          @inbox.ack_message receipt
        end

        def test_nack_message
          mock(@channel).reject 123, true

          receipt = MessageReceipt.new 123, 'packed', @queue_name
          @inbox.nack_message receipt

          mock(@channel).reject 123, false

          @inbox.requeue_on_nack = false
          @inbox.nack_message receipt
        end
      end

    end
  end
end
