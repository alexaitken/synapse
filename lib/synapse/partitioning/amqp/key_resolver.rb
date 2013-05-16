module Synapse
  module Partitioning
    module AMQP
      # Represents a mechanism for determining the routing key to use when publishing a message
      class RoutingKeyResolver
        # Returns the routing key to use when publishing the given message
        #
        # @param [Message] message
        # @return [String]
        def resolve_key(message); end
      end # RoutingKeyResolver

      # Implementation of a routing key resolver that uses the message payload's module name
      class ModuleRoutingKeyResolver
        # @param [Message] message
        # @return [String]
        def resolve_key(message)
          type = message.payload_type.to_s
          type.deconstantize.underscore.tap do |key|
            key.tr! '/', '.'
          end
        end
      end # ModuleRoutingKeyResolver
    end # AMQP
  end # Partitioning
end
