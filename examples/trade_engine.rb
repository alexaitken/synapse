require 'bundler/setup'
require 'active_model'
require 'synapse'
require 'pp'

require_relative 'trade_engine/api'
require_relative 'trade_engine/command'
require_relative 'trade_engine/core_ext'
require_relative 'trade_engine/order'
require_relative 'trade_engine/orderbook'

Logging.logger.root.appenders = Logging.appenders.stdout

include Synapse
include Synapse::Command
include Synapse::EventBus
include Synapse::EventStore
include Synapse::EventSourcing
include Synapse::Repository
include Synapse::UnitOfWork

include TradeEngine

# Begin infrastructure

unit_provider = UnitOfWorkProvider.new
unit_factory = UnitOfWorkFactory.new unit_provider
aggregate_factory = GenericAggregateFactory.new Orderbook
event_bus = SimpleEventBus.new
command_bus = SimpleCommandBus.new unit_factory
command_bus.filters.push ActiveModelValidationFilter.new

event_store = InMemoryEventStore.new

repository = EventSourcingRepository.new aggregate_factory, event_store
repository.event_bus = event_bus
repository.lock_manager = NullLockManager.new
repository.unit_provider = unit_provider

ob_handler = OrderbookCommandHandler.new repository
command_bus.subscribe CreateOrderbookCommand, ob_handler
command_bus.subscribe PlaceBuyOrderCommand, ob_handler
command_bus.subscribe PlaceSellOrderCommand, ob_handler

# End infrastructure

x = 50

orderbook_ids = Array.new

x.times do
  orderbook_id = IdentifierFactory.instance.generate

  command_bus.dispatch as_command(CreateOrderbookCommand.new { |c|
    c.orderbook_id = orderbook_id
  })

  orderbook_ids.push orderbook_id
end

n = 1000

time = Benchmark.realtime do

  n.times do
    command_type = [PlaceBuyOrderCommand, PlaceSellOrderCommand].sample

    command_bus.dispatch as_command(command_type.new { |c|
      c.orderbook_id = orderbook_ids.sample
      c.order_id = IdentifierFactory.instance.generate
      c.trade_count = 10
      c.item_price = 5
    })
  end

end

puts 'Took %ss to handle %s commands' % [time, n]
puts '%s commands/sec' % [n/time]
