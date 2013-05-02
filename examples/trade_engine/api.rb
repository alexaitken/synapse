module TradeEngine
  module Initializer
    def initialize
      yield self if block_given?
    end
  end

  ###################################################
  # Commands
  ###################################################

  class CreateOrderbookCommand
    include ActiveModel::Validations
    include Initializer

    attr_accessor :orderbook_id
    validates_presence_of :orderbook_id
  end

  # @abstract
  class PlaceOrderCommand
    include ActiveModel::Validations
    include Initializer

    attr_accessor :orderbook_id, :order_id, :trade_count, :item_price

    validates :trade_count, numericality: {
      only_integer: true,
      greater_than: 0
    }
    validates :item_price, numericality: {
      greater_than_or_equal_to: 0
    }

    validates_presence_of :orderbook_id, :order_id, :trade_count, :item_price
  end

  class PlaceBuyOrderCommand < PlaceOrderCommand; end
  class PlaceSellOrderCommand < PlaceOrderCommand; end

  ###################################################
  # Events
  ###################################################

  class OrderbookCreatedEvent
    include Initializer
    attr_accessor :orderbook_id
  end

  class BuyOrderPlacedEvent
    include Initializer
    attr_accessor :orderbook_id, :order_id, :trade_count, :item_price
  end

  class SellOrderPlacedEvent
    include Initializer
    attr_accessor :orderbook_id, :order_id, :trade_count, :item_price
  end

  class TradeExecutedEvent
    include Initializer
    attr_accessor :orderbook_id, :buy_order_id, :sell_order_id, :trade_count, :trade_price
  end
end
