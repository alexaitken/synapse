Synapse.build do
  converter_factory
  serializer
  upcaster_chain

  unit_factory
  async_command_bus do
    use_threads 4
  end
  simple_event_bus

  gateway

  mongo_event_store do
    use_client Mongo::MongoClient.new
  end

  snapshot_taker
  interval_snapshot_policy do
    use_threshold 50
  end

  factory :es_cache do
    ActiveSupport::Cache::MemoryStore.new
  end

  es_repository :orderbook_repository do
    use_aggregate_type TradeEngine::OrderBook
    use_cache :es_cache
  end

  factory :orderbook_command_handler, :tag => :command_handler do
    inject_into TradeEngine::OrderBookCommandHandler.new
  end

  factory :validation_filter, :tag => :command_filter do
    Synapse::Command::ActiveModelValidationFilter.new
  end
end
