Synapse.build do
  converter_factory
  serializer
  upcaster_chain

  unit_factory
  simple_command_bus
  simple_event_bus

  gateway

  factory :event_store do
    serializer = resolve :serializer
    upcaster_chain = resolve :upcaster_chain

    client = Mongo::MongoClient.new
    template = Synapse::EventStore::Mongo::Template.new client
    strategy = Synapse::EventStore::Mongo::DocumentPerCommitStrategy.new template, serializer, upcaster_chain

    event_store = Synapse::EventStore::Mongo::MongoEventStore.new template, strategy
    event_store.ensure_indexes

    event_store
  end

  es_repository :orderbook_repository do
    use_aggregate_type TradeEngine::OrderBook
  end

  factory :orderbook_command_handler, :tag => :command_handler do
    inject_into TradeEngine::OrderBookCommandHandler.new
  end
end
