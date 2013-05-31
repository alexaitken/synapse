module Synapse
  module ProcessManager
    # Process that has the wiring DSL built-in
    #
    # @example
    #   class OrderProcess < WiringProcess
    #     wire OrderCreatedEvent, correlate: :order_id, start: true, to: :on_create
    #     wire OrderFinishedEvent, correlate: :order_id, finish: true, to: :on_finish
    #   end
    class WiringProcess < Process
      include Wiring::MessageWiring

      # @param [EventMessage] event
      # @return [undefined]
      def handle(event)
        return unless @active

        wire = self.wire_registry.wire_for event.payload_type

        return unless wire

        invoke_wire event, wire
        finish if wire.options[:finish]
      end
    end # WiringProcess
  end # ProcessManager
end
