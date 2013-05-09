module Synapse
  module EventBus
    # Mixin for an event listener that wishes to use the wiring DSL
    module WiringEventListener
      extend ActiveSupport::Concern
      include EventListener
      include Wiring::MessageWiring

      included do
        self.wire_registry = Wiring::WireRegistry.new true
      end

      # @param [EventMessage] event
      # @return [undefined]
      def notify(event)
        wire = self.wire_registry.wire_for event.payload_type
        if wire
          invoke_wire event, wire
        end
      end
    end
  end
end
