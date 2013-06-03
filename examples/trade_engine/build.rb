Synapse.build do
  converter_factory
  serializer do
    use_ox
    use_serialize_options circular: true
  end
  upcaster_chain

  unit_factory
  simple_command_bus
  simple_event_bus

  gateway

  mongo_event_store do
    use_client Mongo::MongoClient.new
  end

  aggregate_snapshot_taker
  interval_snapshot_policy do
    use_threshold 10
  end

  es_repository :orderbook_repository do
    use_aggregate_type TradeEngine::OrderBook
  end

  factory :orderbook_command_handler, :tag => :command_handler do
    inject_into TradeEngine::OrderBookCommandHandler.new
  end

  factory :validation_filter, :tag => :command_filter do
    Synapse::Command::ActiveModelValidationFilter.new
  end
end
