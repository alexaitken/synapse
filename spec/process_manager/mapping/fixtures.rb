require 'spec_helper'

module Synapse
  module ProcessManager

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

    class OrderProcess < MappingProcess
      attr_reader :handled

      map_event OrderCreated, correlate: :order_id, start: true do
        @handled = (@handled or 0).next
      end

      map_event OrderForceCreated, correlate: :order_id, start: true, force_new: true do
        @handled = (@handled or 0).next
      end

      map_event OrderUpdated, correlate: :order_id do
        @handled = (@handled or 0).next
      end

      map_event OrderCanceled, correlate: :order_id, finish: true do
        @handled = (@handled or 0).next
      end

      map_event OrderDerped, correlate: :derpy_key do; end
    end
  end
end
