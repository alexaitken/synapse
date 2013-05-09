require 'bundler/setup'
require 'active_model'
require 'synapse'
require 'pp'
require 'mongo'

require_relative 'trade_engine/infrastructure'
require_relative 'trade_engine/contracts'
require_relative 'trade_engine/api'
require_relative 'trade_engine/command'
require_relative 'trade_engine/order'
require_relative 'trade_engine/orderbook'
require_relative 'trade_engine/bson'

Logging.logger.root.appenders = Logging.appenders.stdout

include TradeEngine

# Begin infrastructure

Thread.new do
  EventMachine.run
end

infrastructure = Infrastructure.configure do |infra|
  infra.build_bus do |bus|
    bus.with_validation
    bus.with_deduplication
  end

  infra.build_repository do |repo|
    repo.serializer = ActiveModelSerializer.new
    repo.serializer.converter_factory.register OrderedHashToHashConverter.new
    repo.for_aggregate Orderbook
    repo.with_mongo
    # repo.with_snapshotting
  end
end

gateway = infrastructure.gateway
ob_handler = OrderbookCommandHandler.new infrastructure.repository
ob_handler.subscribe infrastructure.command_bus

# End infrastructure

id_factory = Synapse::IdentifierFactory.instance

command_types = [PlaceBuyOrderCommand, PlaceSellOrderCommand]

# Number of orderbooks to create
x = 1000

# Number of orders to submit
n = 100

orderbook_ids = Array.new

time = Benchmark.realtime do

  x.times do
    orderbook_id = id_factory.generate
    orderbook_ids.push orderbook_id

    gateway.send CreateOrderbookCommand.new { |c|
      c.orderbook_id = orderbook_id
    }
  end

  n.times do
    gateway.send command_types.sample.new { |c|
      c.orderbook_id = orderbook_ids.sample
      c.order_id = id_factory.generate
      c.trade_count = 10
      c.item_price = 5
    }
  end

end

t = x + n

overall = time.round(2)
latency = (time/t * 1000).round(1)
throughput = (t/time).round

puts '   Overall: Took %ss to handle %s commands' % [overall, t]
puts 'Throughput: %s commands/sec' % [throughput]
puts '   Latency: %sms' % [latency]
