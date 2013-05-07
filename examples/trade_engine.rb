require 'bundler/setup'
require 'active_model'
require 'synapse'
require 'pp'
require 'mongo'

require_relative 'trade_engine/api'
require_relative 'trade_engine/command'
require_relative 'trade_engine/order'
require_relative 'trade_engine/orderbook'

Logging.logger.root.appenders = Logging.appenders.stdout
# Logging.logger.root.level = :warn

include Synapse
include Synapse::Command
include Synapse::EventBus
include Synapse::EventStore::Mongo
include Synapse::EventSourcing
include Synapse::Repository
include Synapse::Serialization
include Synapse::UnitOfWork
include Synapse::Upcasting

include TradeEngine

# Begin infrastructure

Thread.new do
  EventMachine.run
end

mongo_client = Mongo::MongoClient.new
template = DefaultMongoTemplate.new mongo_client

unit_provider = UnitOfWorkProvider.new
unit_factory = UnitOfWorkFactory.new unit_provider
aggregate_factory = GenericAggregateFactory.new Orderbook
event_bus = SimpleEventBus.new
command_bus = SimpleCommandBus.new unit_factory
command_bus.interceptors.push SerializationOptimizingInterceptor.new
# command_bus.filters.push ActiveModelValidationFilter.new

serializer = OxSerializer.new
serializer.serialize_options = {
  circular: true
}

upcaster_chain = UpcasterChain.new serializer.converter_factory

strategy = DocumentPerCommitStrategy.new template, serializer, upcaster_chain
# strategy = DocumentPerEventStrategy.new template, serializer, upcaster_chain
event_store = MongoEventStore.new template, strategy
event_store.ensure_indexes
# event_store = InMemoryEventStore.new

aggregate_taker = AggregateSnapshotTaker.new event_store
aggregate_taker.register_factory aggregate_factory
# deferred_taker = DeferredSnapshotTaker.new aggregate_taker
snapshot_trigger = EventCountSnapshotTrigger.new aggregate_taker, unit_provider

#lock_manager = PessimisticLockManager.new
lock_manager = NullLockManager.new
repository = EventSourcingRepository.new aggregate_factory, event_store, lock_manager
repository.event_bus = event_bus
repository.unit_provider = unit_provider
# repository.add_stream_decorator snapshot_trigger

ob_handler = OrderbookCommandHandler.new repository
command_bus.subscribe CreateOrderbookCommand, ob_handler
command_bus.subscribe PlaceBuyOrderCommand, ob_handler
command_bus.subscribe PlaceSellOrderCommand, ob_handler

gateway = CommandGateway.new command_bus

# End infrastructure

x = 100

orderbook_ids = Array.new

x.times do
  orderbook_id = IdentifierFactory.instance.generate
  orderbook_ids.push orderbook_id

  gateway.send CreateOrderbookCommand.new { |c|
    c.orderbook_id = orderbook_id
  }
end

command_types = [PlaceBuyOrderCommand, PlaceSellOrderCommand]

n = 1000

time = Benchmark.realtime do

  n.times do |i|
    gateway.send command_types.sample.new { |c|
      c.orderbook_id = orderbook_ids.sample
      c.order_id = IdentifierFactory.instance.generate
      c.trade_count = 10
      c.item_price = 5
    }
  end

end

overall = time.round(2)
latency = (time/n * 1000).round(1)
throughput = (n/time).round

puts '   Overall: Took %ss to handle %s commands' % [overall, n]
puts 'Throughput: %s commands/sec' % [throughput]
puts '   Latency: %sms' % [latency]
