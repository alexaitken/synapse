module TradeEngine
  class OrderBookCreatedEvent
    attr_reader :orderbook_id

    def initialize(orderbook_id)
      @orderbook_id = orderbook_id
    end
  end

  # @abstract
  class OrderPlacedEvent
    attr_reader :orderbook_id, :order_id, :trade_count, :item_price

    def initialize(orderbook_id, order_id, trade_count, item_price)
      @orderbook_id = orderbook_id
      @order_id = order_id
      @trade_count = trade_count
      @item_price = item_price
    end
  end

  class BuyOrderPlacedEvent < OrderPlacedEvent; end
  class SellOrderPlacedEvent < OrderPlacedEvent; end

  class TradeExecutedEvent
    attr_reader :orderbook_id, :buy_order_id, :sell_order_id, :trade_count, :item_price

    def initialize(orderbook_id, buy_order_id, sell_order_id, trade_count, item_price)
      @orderbook_id = orderbook_id
      @buy_order_id = buy_order_id
      @sell_order_id = sell_order_id
      @trade_count = trade_count
      @item_price = item_price
    end
  end
end
