require 'spec_helper'

module Synapse
  module Saga

    class OrderEvent
      attr_reader :order_id
      def initialize(order_id)
        @order_id = order_id
      end
    end

    class OrderCreated < OrderEvent; end
    class OrderForceCreated < OrderEvent; end
    class OrderUpdated < OrderEvent; end
    class OrderCanceled < OrderEvent; end
    class OrderDerped; end

    class OrderSaga < MappingSaga
      attr_reader :handled

      def initialize(id = nil)
        super
        @handled = 0
      end

      map_event OrderCreated, correlate: :order_id, start: true do
        @handled += 1
      end

      map_event OrderForceCreated, correlate: :order_id, start: true, force_new: true do
        @handled += 1
      end

      map_event OrderUpdated, correlate: :order_id do
        @handled += 1
      end

      map_event OrderCanceled, correlate: :order_id, finish: true do
        @handled += 1
      end

      map_event OrderDerped, correlate: :derpy_key do; end
    end
  end
end
