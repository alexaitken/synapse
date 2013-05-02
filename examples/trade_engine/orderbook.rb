module TradeEngine
  class Orderbook
    include Synapse::EventSourcing::AggregateRoot

    child_entity :buy_orders, :sell_orders

    def initialize(identifier)
      apply OrderbookCreatedEvent.new { |e|
        e.orderbook_id = identifier
      }
    end

    def add_buy_order(order_id, trade_count, item_price)
      apply BuyOrderPlacedEvent.new { |e|
        e.orderbook_id = @identifier
        e.order_id = order_id
        e.trade_count = trade_count
        e.item_price = item_price
      }
      execute_trades
    end

    def add_sell_order(order_id, trade_count, item_price)
      apply SellOrderPlacedEvent.new { |e|
        e.orderbook_id = @identifier
        e.order_id = order_id
        e.trade_count = trade_count
        e.item_price = item_price
      }
      execute_trades
    end

  private

    def handle_event(event)
      e = event.payload

      if e.is_a? OrderbookCreatedEvent
        @id = e.orderbook_id
      elsif e.is_a? BuyOrderPlacedEvent
        buy_orders.add Order.new e.order_id, e.item_price, e.trade_count
      elsif e.is_a? SellOrderPlacedEvent
        sell_orders.add Order.new e.order_id, e.item_price, e.trade_count
      elsif e.is_a? TradeExecutedEvent
        # Cleans up after the last trade execution
        highest_buyer = buy_orders.last
        lowest_seller = sell_orders.first

        if highest_buyer.items_remaining <= e.trade_count
          buy_orders.delete highest_buyer
        end

        if lowest_seller.items_remaining <= e.trade_count
          sell_orders.delete lowest_seller
        end
      end
    end

    def buy_orders
      @buy_orders ||= SortedSet.new
    end

    def sell_orders
      @sell_orders ||= SortedSet.new
    end

    def execute_trades
      done = false
      until done or buy_orders.empty? or sell_orders.empty?
        highest_buyer = buy_orders.last
        lowest_seller = sell_orders.first

        if highest_buyer.item_price >= lowest_seller.item_price
          matched_trade_count = [highest_buyer.items_remaining, lowest_seller.items_remaining].min
          matched_trade_price = (highest_buyer.item_price + lowest_seller.item_price) / 2

          apply TradeExecutedEvent.new { |e|
            e.orderbook_id = @id
            e.buy_order_id = highest_buyer.identifier
            e.sell_order_id = lowest_seller.identifier
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
