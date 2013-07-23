$:.push File.expand_path '../lib', __FILE__

require 'bundler/setup'
require 'trade_engine'
require 'pp'

require_relative 'build'

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info

command_bus = Synapse.container[:command_bus]
gateway = Synapse.container[:gateway]

x = 1000 # Number of order books to create
n = 10000 # Number of orders to place

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
    gateway.send command
  end

  until command_bus.thread_pool.backlog == 0
    sleep 1
  end

  n.times do
    orderbook_id = orderbook_identifiers.sample
    order_id = SecureRandom.uuid
    trade_count = 50
    item_price = 10

    order_type = order_types.sample

    command = order_type.new orderbook_id, order_id, trade_count, item_price
    gateway.send command
  end

  command_bus.shutdown
end

t = x + n

overall = time.round 2
latency = (time/t * 1000).round 1
throughput = (t/time).round

puts "   Overall: Took #{overall}s to handle #{t} commands"
puts "Throughput: #{thoughput} commands/sec"
puts "   Latency: #{latency}ms"
