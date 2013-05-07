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

  private

    def handle_event(event)
      e = event.payload

      if e.is_a? TradeExecutedEvent
        if e.buy_order_id == @id or e.sell_order_id == @id
          record_traded e.trade_count
        end
      end
    end

    def record_traded(trade_count)
      @items_remaining -= trade_count
    end
  end
end