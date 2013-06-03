module TradeEngine
  class OrderBookCommandHandler
    include Synapse::Command::MappingCommandHandler
    include Synapse::Configuration::Dependent

    depends_on :orderbook_repository

    map_command CreateOrderBookCommand do |command|
      orderbook = OrderBook.new command.orderbook_id
      @orderbook_repository.add orderbook
    end

    map_command PlaceBuyOrderCommand do |command|
      orderbook = @orderbook_repository.load command.orderbook_id
      orderbook.add_buy_order command.order_id, command.trade_count, command.item_price
    end

    map_command PlaceSellOrderCommand do |command|
      orderbook = @orderbook_repository.load command.orderbook_id
      orderbook.add_sell_order command.order_id, command.trade_count, command.item_price
    end
  end
end
