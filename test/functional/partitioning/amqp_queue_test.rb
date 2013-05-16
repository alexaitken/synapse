require 'test_helper'
require 'amqp'
require 'partitioning/amqp/fixtures'

module Synapse
  module Partitioning
    module AMQP
      class QueueTest < Test::Unit::TestCase

        def test_integration
          Thread.new do
            EventMachine.run
          end

          wait_until { EventMachine.reactor_running? }

          connection = ::AMQP.start

          wait_until { connection.connected? }

          channel = ::AMQP::Channel.new connection
          exchange = channel.topic 'synapse_integration_test', auto_delete: true

          queue = channel.queue 'synapse_integration_test_queue', auto_delete: true
          # We should get this routing key from the payload of the event message below
          queue.bind exchange, routing_key: 'trade_engine.#'

          key_resolver = ModuleRoutingKeyResolver.new

          outbox = AMQPQueueWriter.new exchange, key_resolver
          inbox = AMQPQueueReader.new queue, channel

          message = Domain::EventMessage.build do |builder|
            builder.payload = TradeEngine::Core::TestEvent.new
          end

          packed_message = 'packed-message'

          count = 0

          inbox.subscribe do |receipt|
            count = count.next
            inbox.ack_message receipt

            assert_equal packed_message, receipt.packed
          end

          outbox.put_message packed_message, message
          outbox.put_message packed_message, message

          wait_until do
            count == 2
          end

          EventMachine.stop
        end

      private

        def wait_until(interval = 0.01, &block)
          until !!block.call
            sleep interval
          end
        end

      end
    end
  end
end
