module Synapse
  module Configuration
    # Definition builder used to create a simple event bus
    #
    # @example The minimum possible effort to build an event bus
    #   simple_event_bus
    #
    # @example Create an event bus with an alternate identifier and listener tag
    #   simple_event_bus :alt_event_bus do
    #     use_listener_tag :alt_event_listener
    #   end
    class SimpleEventBusDefinitionBuilder < DefinitionBuilder
      # Changes the tag to use to automatically subscribe event listeners
      #
      # @param [Symbol] listener_tag
      # @return [undefined]
      def use_listener_tag(listener_tag)
        @listener_tag = listener_tag
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :event_bus

        use_listener_tag :event_listener

        use_factory do
          event_bus = EventBus::SimpleEventBus.new

          with_tagged @listener_tag do |listener|
            event_bus.subscribe listener
          end

          event_bus
        end
      end
    end # SimpleEventBusDefinitionBuilder
  end # Configuration
end
