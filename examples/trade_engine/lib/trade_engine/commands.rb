module TradeEngine
  class CreateOrderBookCommand
    include ActiveModel::Validations

    attr_reader :orderbook_id
    validates_presence_of :orderbook_id

    def initialize(orderbook_id)
      @orderbook_id = orderbook_id
    end
  end

  # @abstract
  class PlaceOrderCommand
    include ActiveModel::Validations

    attr_reader :orderbook_id, :order_id, :trade_count, :item_price
    validates_presence_of :orderbook_id, :order_id, :trade_count, :item_price

    validates :trade_count, :numericality => {
      :only_integer => true,
      :greater_than => 0
    }

    validates :item_price, :numericality => {
      :greater_than_or_equal_to => 0
    }

    def initialize(orderbook_id, order_id, trade_count, item_price)
      @orderbook_id = orderbook_id
      @order_id = order_id
      @trade_count = trade_count
      @item_price = item_price
    end
  end

  class PlaceBuyOrderCommand < PlaceOrderCommand; end
  class PlaceSellOrderCommand < PlaceOrderCommand; end
end
