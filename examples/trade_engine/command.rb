module TradeEngine
  class OrderbookCommandHandler
    include Synapse::Command::CommandHandler

    def initialize(repository)
      @repository = repository
    end

    def handle(command, unit)
      payload = command.payload
      payload_type = command.payload_type

      if payload_type.eql? CreateOrderbookCommand
        on_create payload
      elsif payload_type.eql? PlaceBuyOrderCommand
        on_buy payload
      elsif payload_type.eql? PlaceSellOrderCommand
        on_sell payload
      end
    end

  private

    def on_create(command)
      orderbook = Orderbook.new command.orderbook_id
      @repository.add orderbook
    end

    def on_buy(command)
      orderbook = @repository.load command.orderbook_id
      orderbook.add_buy_order command.order_id, command.trade_count, command.item_price
    end

    def on_sell(command)
      orderbook = @repository.load command.orderbook_id
      orderbook.add_sell_order command.order_id, command.trade_count, command.item_price
    end
  end
end
