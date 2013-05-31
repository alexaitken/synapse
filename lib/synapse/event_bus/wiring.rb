module Synapse
  module EventBus
    # Mixin for an event listener that wishes to use the wiring DSL
    module WiringEventListener
      extend ActiveSupport::Concern
      include EventListener
      include Wiring::MessageWiring

      # @param [EventMessage] event
      # @return [undefined]
      def notify(event)
        wire = wire_registry.wire_for event.payload_type

        return unless wire

        invoke_wire event, wire
      end
    end
  end
end
