module Synapse
  module Command
    # Mixin for a command handler that wishes to use the wiring DSL
    module WiringCommandHandler
      extend ActiveSupport::Concern
      include CommandHandler
      include Wiring::MessageWiring

      included do
        self.wire_registry = Wiring::WireRegistry.new false
      end

      # @param [CommandMessage] command
      # @param [UnitOfWork] current_unit Current unit of work
      # @return [Object] The result of handling the given command
      def handle(command, current_unit)
        wire = wire_registry.wire_for command.payload_type

        unless wire
          raise ArgumentError, 'Not capable of handling [%s] commands' % command.payload_type
        end

        invoke_wire command, wire
      end

      # Subscribes this handler to the given command bus for any types that have been wired
      #
      # @param [CommandBus] command_bus
      # @return [undefined]
      def subscribe(command_bus)
        self.wire_registry.each_type do |type|
          command_bus.subscribe type, self
        end
      end

      # Unsubscribes this handler from the given command bus for any types that have been wired
      #
      # @param [CommandBus] command_bus
      # @return [undefined]
      def unsubscribe(command_bus)
        self.wire_registry.each_type do |type|
          command_bus.unsubscribe type, self
        end
      end
    end # WiringCommandHandler
  end # Command
end
