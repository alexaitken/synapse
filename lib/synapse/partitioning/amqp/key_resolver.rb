module Synapse
  module Partitioning
    module AMQP
      class RoutingKeyResolver
        # @param [Message] message
        # @return [String]
        def resolve_key(message); end
      end

      class ModuleRoutingKeyResolver
        # @param [Message] message
        # @return [String]
        def resolve_key(message)
          payload = message.payload_type.to_s
          payload.deconstantize.underscore.tap do |key|
            key.tr! '/', '.'
          end
        end
      end
    end # AMQP
  end # Partitioning
end # Synapse
