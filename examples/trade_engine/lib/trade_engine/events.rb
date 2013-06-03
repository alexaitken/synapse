module TradeEngine
  class OrderBookCreatedEvent
    include Virtus

    attribute :orderbook_id, String

    def self.create(orderbook_id)
      self.new orderbook_id: orderbook_id
    end
  end

  # @abstract
  class OrderPlacedEvent
    include Virtus

    attribute :orderbook_id, String
    attribute :order_id, String
    attribute :trade_count, Integer
    attribute :item_price, Float

    def self.create(orderbook_id, order_id, trade_count, item_price)
      order_attributes = {
        orderbook_id: orderbook_id,
        order_id: order_id,
        trade_count: trade_count,
        item_price: item_price
      }

      self.new order_attributes
    end
  end

  class BuyOrderPlacedEvent < OrderPlacedEvent; end
  class SellOrderPlacedEvent < OrderPlacedEvent; end

  class TradeExecutedEvent
    include Virtus

    attribute :orderbook_id, String
    attribute :buy_order_id, String
    attribute :sell_order_id, String
    attribute :trade_count, Integer
    attribute :item_price, Float

    def self.create(orderbook_id, buy_order_id, sell_order_id, trade_count, item_price)
      trade_attrbutes = {
        orderbook_id: orderbook_id,
        buy_order_id: buy_order_id,
        sell_order_id: sell_order_id,
        trade_count: trade_count,
        item_price: item_price
      }

      self.new trade_attrbutes
    end
  end
end
