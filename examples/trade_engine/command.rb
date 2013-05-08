module TradeEngine
  class OrderbookCommandHandler
    include Synapse::Command::WiringCommandHandler

    def initialize(repository)
      @repository = repository
    end

    wire CreateOrderbookCommand do |command|
      orderbook = Orderbook.new command.orderbook_id
      @repository.add orderbook
    end

    wire PlaceBuyOrderCommand do |command|
      orderbook = @repository.load command.orderbook_id
      orderbook.add_buy_order command.order_id, command.trade_count, command.item_price
    end

    wire PlaceSellOrderCommand do |command|
      orderbook = @repository.load command.orderbook_id
      orderbook.add_sell_order command.order_id, command.trade_count, command.item_price
    end
  end
end
