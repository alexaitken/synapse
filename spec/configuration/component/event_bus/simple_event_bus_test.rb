require 'test_helper'

module Synapse
  module Configuration
    describe SimpleEventBusDefinitionBuilder do
      def setup
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      should 'build with sensible defaults' do
        @builder.simple_event_bus

        factory = @container.resolve :event_bus
        assert factory.is_a? EventBus::SimpleEventBus
      end

      should 'build and subscribe tagged event listeners' do
        @builder.definition :first_listener do
          tag :event_listener
          use_factory do
            TestEventListener.new
          end
        end

        @builder.definition :second_listener do
          tag :alt_event_listener
          use_factory do
            TestAltEventListener.new
          end
        end

        # Defaults
        @builder.simple_event_bus

        event_bus = @container.resolve :event_bus
        assert event_bus.subscribed? @container.resolve :first_listener
        refute event_bus.subscribed? @container.resolve :second_listener

        # Customized
        @builder.simple_event_bus :alt_event_bus do
          use_listener_tag :alt_event_listener
        end

        event_bus = @container.resolve :alt_event_bus
        refute event_bus.subscribed? @container.resolve :first_listener
        assert event_bus.subscribed? @container.resolve :second_listener
      end
    end

    class TestEventListener
      include EventBus::MappingEventListener
    end
    class TestAltEventListener
      include EventBus::MappingEventListener
    end
  end
end
