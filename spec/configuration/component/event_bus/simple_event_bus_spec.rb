require 'spec_helper'

module Synapse
  module Configuration

    describe SimpleEventBusDefinitionBuilder do
      before do
        @container = Container.new
        @builder = ContainerBuilder.new @container
      end

      it 'builds with sensible defaults' do
        @builder.simple_event_bus

        event_bus = @container.resolve :event_bus
        event_bus.should be_a(EventBus::SimpleEventBus)
      end

      it 'builds and subscribes tagged event listeners' do
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
        event_bus.subscribed?(@container.resolve(:first_listener)).should be_true
        event_bus.subscribed?(@container.resolve(:second_listener)).should be_false

        # Customized
        @builder.simple_event_bus :alt_event_bus do
          use_listener_tag :alt_event_listener
        end

        event_bus = @container.resolve :alt_event_bus
        event_bus.subscribed?(@container.resolve(:first_listener)).should be_false
        event_bus.subscribed?(@container.resolve(:second_listener)).should be_true
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
