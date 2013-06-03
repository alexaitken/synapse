$:.push File.expand_path '../lib', __FILE__

require 'bundler/setup'
require 'trade_engine'
require 'pp'

require_relative 'build'

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info

gateway = Synapse.container[:gateway]

x = 100 # Number of order books to create
n = 1000 # Number of orders to place

orderbook_identifiers = Array.new
order_types = [
  TradeEngine::PlaceBuyOrderCommand,
  TradeEngine::PlaceSellOrderCommand
]

time = Benchmark.realtime do
  x.times do
    orderbook_id = SecureRandom.uuid
    orderbook_identifiers.push orderbook_id

    command = TradeEngine::CreateOrderBookCommand.new orderbook_id
    gateway.send_and_wait command
  end

  n.times do
    orderbook_id = orderbook_identifiers.sample
    order_id = SecureRandom.uuid
    trade_count = 50
    item_price = 10

    order_type = order_types.sample

    command = order_type.new orderbook_id, order_id, trade_count, item_price
    gateway.send_and_wait command
  end
end

t = x + n

overall = time.round 2
latency = (time/t * 1000).round 1
throughput = (t/time).round

puts '   Overall: Took %ss to handle %s commands' % [overall, t]
puts 'Throughput: %s commands/sec' % [throughput]
puts '   Latency: %sms' % [latency]
