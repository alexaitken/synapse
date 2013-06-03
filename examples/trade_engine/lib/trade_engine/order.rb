module TradeEngine
  class Order
    include Synapse::EventSourcing::Entity

    attr_reader :id, :item_price, :trade_count, :items_remaining

    def initialize(id, item_price, trade_count)
      @id = id
      @item_price = item_price
      @trade_count = @items_remaining = trade_count
    end

    def <=>(other)
      @item_price <=> other.item_price
    end

  protected

    map_event TradeExecutedEvent do |event|
      if event.buy_order_id == @id or event.sell_order_id == @id
        record_traded event.trade_count
      end
    end

    def record_traded(trade_count)
      @items_remaining = @items_remaining - trade_count
    end
  end
end
