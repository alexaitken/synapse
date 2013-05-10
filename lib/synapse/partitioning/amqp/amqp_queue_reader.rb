module Synapse
  module Partitioning
    module AMQP
      # Implementation of a queue reader that subscribes to an AMQP queue
      class AMQPQueueReader < QueueReader
        # The behavior when a message is not acknowledged by a message handler
        #
        # When a message is explicitly rejected, this usually indicates that there was an
        # error while processing the message. When the message is rejected, it can either be
        # put back on the queue so that it can be retried later, or it can be routed as a dead
        # letter if using RabbitMQ.
        #
        # @see http://www.rabbitmq.com/dlx.html
        # @return [Boolean] Default value is true
        attr_accessor :requeue_on_nack

        # @param [AMQP::Queue] queue
        # @param [AMQP::Channel] channel
        # @param [MessageUnpacker] unpacker
        # @return [undefined]
        def initialize(queue, channel, unpacker)
          @queue = queue
          @channel = channel
          @requeue_on_nack = true
        end

        # @yield [MessageReceipt] Receipt of the message taken off the queue
        # @return [undefined]
        def subscribe(&handler)
          @queue.subscribe do |headers, packed|
            receipt = MessageReceipt.new headers.delivery_tag, packed, @queue.name
            handler.call receipt
          end
        end

        # @param [MessageReceipt] receipt
        # @return [undefined]
        def ack_message(receipt)
          @channel.acknowledge receipt.tag
        end

        # @param [MessageReceipt] receipt
        # @return [undefined]
        def nack_message(receipt)
          @channel.reject receipt.tag, @requeue_on_nack
        end
      end # AMQPQueueReader
    end # AMQP
  end # Partitioning
end # Synapse
