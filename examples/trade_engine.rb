require 'bundler/setup'
require 'active_model'
require 'synapse'
require 'synapse-mongo'
require 'pp'

require_relative 'trade_engine/contracts'
require_relative 'trade_engine/api'
require_relative 'trade_engine/command'
require_relative 'trade_engine/order'
require_relative 'trade_engine/orderbook'
require_relative 'trade_engine/build'

container = Synapse.container

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info

include TradeEngine

# Begin infrastructure

Thread.new do
  EventMachine.run
end

command_bus = container.fetch :command_bus
# TODO Service?
gateway = Synapse::Command::CommandGateway.new command_bus

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
