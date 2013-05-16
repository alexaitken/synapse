module Synapse
  module Partitioning
    module AMQP
      # Implementation of a queue writer that publishes packed messages to an AMQP exchange
      class AMQPQueueWriter < QueueWriter
        # @return [Hash] Additional options that will be used when publishing messages
        attr_accessor :publish_options

        # @param [AMQP::Exchange] exchange
        # @param [RoutingKeyResolver] key_resolver
        # @return [undefined]
        def initialize(exchange, key_resolver)
          @exchange = exchange
          @key_resolver = key_resolver
          @publish_options = Hash.new
        end

        # @param [Object] packed
        # @param [Message] unpacked
        # @return [undefined]
        def put_message(packed, unpacked)
          publish_options = {
            routing_key: @key_resolver.resolve_key(unpacked)
          }

          @exchange.publish(packed, @publish_options.merge(publish_options))
        end
      end # AMQPQueueWriter
    end # AMQP
  end # Partitioning
end
