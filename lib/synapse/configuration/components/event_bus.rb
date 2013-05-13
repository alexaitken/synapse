module Synapse
  module Configuration
    # Extension to container builder that adds a simple event bus builder
    class ContainerBuilder
      # @yield [SimpleEventBusDefinitionBuilder]
      # @return [undefined]
      def simple_event_bus(&block)
        with_builder SimpleEventBusDefinitionBuilder, &block
      end
    end

    # Service definition builder that makes it easier to use a simple event bus
    class SimpleEventBusDefinitionBuilder < ServiceDefinitionBuilder
      # @return [Symbol] Tag to use to lookup listeners to subscribe to this event bus
      attr_accessor :listener_tag

    protected

      # @return [undefined]
      def populate_defaults
        @id = :event_bus

        @listener_tag = :event_listener

        with_factory do
          event_bus = EventBus::SimpleEventBus.new
          event_bus.tap do
            subscribe_listeners event_bus
          end
        end
      end

    private

      # @param [SimpleEventBus] event_bus
      # @return [undefined]
      def subscribe_listeners(event_bus)
        listeners = @container.fetch_tagged @listener_tag
        listeners.each do |listener|
          event_bus.subscribe listener
        end
      end
    end # SimpleEventBusDefinitionBuilder
  end # Configuration
end
