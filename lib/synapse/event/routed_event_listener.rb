module Synapse
  module Event
    # Base implementation of an event listener that provides the message routing DSL out of
    # the box
    #
    # @example
    #   class AccountEventListener
    #     include Synapse::Event::RoutedEventListener
    #
    #     route_event TransferSuccessful do |event|
    #       # Do something with the event here
    #     end
    #   end
    module RoutedEventListener
      extend ActiveSupport::Concern
      include EventListener

      included do
        inherit_accessor :event_router do
          Router.create_router
        end
      end

      module ClassMethods
        # @see MessageRouter#route
        # @return [undefined]
        def route_event(*args, &block)
          event_router.route self, *args, &block
        end
      end

      # @param [EventMessage] event
      # @return [undefined]
      def notify(event)
        handler = event_router.handler_for event
        if handler
          handler.invoke self, event
        end
      end
    end # RoutedEventListener
  end # Event
end
