module TradeEngine
  class Orderbook
    include Synapse::EventSourcing::AggregateRoot

    child_entity :buy_orders, :sell_orders

    def initialize(identifier)
      pre_initialize
      apply OrderbookCreatedEvent.new { |e|
        e.orderbook_id = identifier
      }
    end

    def add_buy_order(order_id, trade_count, item_price)
      apply BuyOrderPlacedEvent.new { |e|
        e.orderbook_id = @id
        e.order_id = order_id
        e.trade_count = trade_count
        e.item_price = item_price
      }
      execute_trades
    end

    def add_sell_order(order_id, trade_count, item_price)
      apply SellOrderPlacedEvent.new { |e|
        e.orderbook_id = @id
        e.order_id = order_id
        e.trade_count = trade_count
        e.item_price = item_price
      }
      execute_trades
    end

  protected

    wire OrderbookCreatedEvent do |event|
      @id = event.orderbook_id
    end

    wire BuyOrderPlacedEvent do |event|
      @buy_orders.push Order.new event.order_id, event.item_price, event.trade_count
    end

    wire SellOrderPlacedEvent do |event|
      @sell_orders.push Order.new event.order_id, event.item_price, event.trade_count
    end

    wire TradeExecutedEvent do |event|
      # Cleans up after the last trade execution
      highest_buyer = @buy_orders.last
      lowest_seller = @sell_orders.first

      if highest_buyer.items_remaining <= event.trade_count
        @buy_orders.delete highest_buyer
      end

      if lowest_seller.items_remaining <= event.trade_count
        @sell_orders.delete lowest_seller
      end
    end

    def pre_initialize
      @buy_orders = Array.new
      @sell_orders = Array.new
    end

    def execute_trades
      done = false

      @buy_orders.sort!
      @sell_orders.sort!

      until done or @buy_orders.empty? or @sell_orders.empty?
        highest_buyer = @buy_orders.last
        lowest_seller = @sell_orders.first

        if highest_buyer.item_price >= lowest_seller.item_price
          matched_trade_count = [highest_buyer.items_remaining, lowest_seller.items_remaining].min
          matched_trade_price = (highest_buyer.item_price + lowest_seller.item_price) / 2

          apply TradeExecutedEvent.new { |e|
            e.orderbook_id = @id
            e.buy_order_id = highest_buyer.id
            e.sell_order_id = lowest_seller.id
            e.trade_count = matched_trade_count
            e.trade_price = matched_trade_price
          }
        else
          done = true
        end
      end
    end
  end
end
