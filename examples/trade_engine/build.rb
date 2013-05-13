Synapse.build do
  service do |service|
    service.id = :orderbook_command_handler
    service.tag :command_handler
    service.with_factory do |container|
      repository = container.fetch :orderbook_repository
      TradeEngine::OrderbookCommandHandler.new repository
    end
  end

  # Setup the Ox serializer
  service do |service|
    service.id = :serializer
    service.with_factory do |container|
      converter_factory = container.fetch :converter_factory

      serializer = Synapse::Serialization::OxSerializer.new converter_factory
      serializer.tap do
        serializer.serialize_options = {
          circular: true
        }
      end
    end
  end

  # Setup the Mongo event store
  # TODO Extract this out to the synapse-mongo gem
  service do |service|
    service.id = :some_event_store
    service.with_factory do |container|
      converter_factory = container.fetch :converter_factory
      serializer = container.fetch :serializer
      upcaster_chain = Synapse::Upcasting::UpcasterChain.new converter_factory

      client = Mongo::MongoClient.new
      template = Synapse::EventStore::Mongo::Template.new client
      strategy = Synapse::EventStore::Mongo::DocumentPerCommitStrategy.new template, serializer, upcaster_chain

      event_store = Synapse::EventStore::Mongo::MongoEventStore.new template, strategy
      event_store.tap do
        event_store.ensure_indexes
      end
    end
  end

  # Setup a simple event bus for aggregate events using defaults
  simple_event_bus

  # Setup the converter factory using defaults
  converter_factory

  # Setup the event-sourcing repository for orderbooks
  event_sourcing do |es|
    es.id = :orderbook_repository
    es.event_store = :some_event_store
    es.for_aggregate TradeEngine::Orderbook
  end

  # Setup the command bus
  simple_command_bus do |bus|
    # Enable ALL THE THINGS
    bus.with_all
  end
end
