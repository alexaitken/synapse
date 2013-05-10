module Synapse
  module Partitioning
    module AMQP
      class AMQPQueueWriter < QueueWriter
        # @return [Hash]
        attr_accessor :publish_options

        # @param [RoutingKeyResolver] key_resolver
        # @return [undefined]
        def initialize(key_resolver)
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
end # Synapse
