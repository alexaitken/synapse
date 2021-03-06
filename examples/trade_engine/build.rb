Synapse.build_with_defaults do
  async_command_bus do
    use_pool_options size: 4, non_block: true
  end

  mongo_event_store do
    use_client Mongo::MongoClient.new
  end

  snapshot_taker
  interval_snapshot_policy do
    use_threshold 30
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
