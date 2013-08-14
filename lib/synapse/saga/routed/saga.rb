module Synapse
  module Saga
    # Saga that has the mapping DSL built-in
    #
    # @example
    #   class OrderSaga < RoutedSaga
    #     route_event OrderCreated, correlate: :order_id, start: true do |event|
    #       # ...
    #     end
    #
    #     route_event OrderCompleted, correlate: :order_id, finish: true, to: :on_finish
    #   end
    #
    # @abstract
    class RoutedSaga < Saga
      # @return [MessageRouter]
      inherit_accessor :event_router do
        Router.create_router
      end

      # @see MessageRouter#route
      # @return [undefined]
      def self.route_event(*args, &block)
        event_router.route self, *args, &block
      end

      # @param [EventMessage] event
      # @return [undefined]
      def handle(event)
        return unless @active

        handler = event_router.handler_for event
        if handler
          handler.invoke self, event
          finish if handler.options[:finish]
        end
      end
    end # RoutedSaga
  end # Saga
end
