module TradeEngine
  class Infrastructure
    attr_reader :gateway
    attr_reader :command_bus
    attr_reader :event_bus
    attr_reader :unit_provider
    attr_reader :unit_factory
    attr_reader :repository

    def initialize
      @unit_provider = Synapse::UnitOfWork::UnitOfWorkProvider.new
      @unit_factory = Synapse::UnitOfWork::UnitOfWorkFactory.new @unit_provider
      @event_bus = Synapse::EventBus::SimpleEventBus.new
    end

    def self.configure
      infra = self.new
      yield infra
      infra
    end

    def build_bus
      builder = CommandBusBuilder.new self
      yield builder
      @command_bus = builder.build
      @gateway = Synapse::Command::CommandGateway.new @command_bus
    end

    def build_repository
      builder = EventSourcingRepositoryBuilder.new self
      yield builder
      @repository = builder.build
    end
  end

  class CommandBusBuilder
    def initialize(infrastructure)
      @infrastructure = infrastructure
      @command_bus = Synapse::Command::SimpleCommandBus.new infrastructure.unit_factory
      @command_bus.interceptors.push Synapse::Command::SerializationOptimizingInterceptor.new
    end

    def build
      @command_bus
    end

    def with_validation
      @command_bus.filters.push Synapse::Command::ActiveModelValidationFilter.new
    end

    def with_deduplication
      @recorder = Synapse::DuplicationRecorder.new
      @command_bus.interceptors.push Synapse::Command::DuplicationCleanupInterceptor.new @recorder
      @command_bus.filters.push Synapse::Command::DuplicationFilter.new @recorder
    end
  end

  class EventSourcingRepositoryBuilder
    attr_accessor :serializer

    def initialize(infrastructure)
      @infrastructure = infrastructure
      @lock_manager = Synapse::Repository::NullLockManager.new
    end

    def build
      repository = Synapse::EventSourcing::EventSourcingRepository.new @aggregate_factory, @event_store, @lock_manager
      repository.event_bus = @infrastructure.event_bus
      repository.unit_provider = @infrastructure.unit_provider

      if @snapshot_trigger
        repository.add_stream_decorator @snapshot_trigger
      end

      repository
    end

    def for_aggregate(type)
      @aggregate_factory = Synapse::EventSourcing::GenericAggregateFactory.new type
    end

    def with_attribute
      @serializer = Synapse::Serialization::AttributeSerializer.new
    end

    def with_marshal
      @serializer = Synapse::Serialization::MarshalSerializer.new
    end

    def with_oj
      @serializer = Synapse::Serialization::OjSerializer.new
    end

    def with_ox
      @serializer = Synapse::Serialization::OxSerializer.new
      @serializer.serialize_options = {
        circular: true
      }
    end

    def with_mongo
      if @serializer.can_serialize_to? Hash
        # Need this for compat if we're using a hash based serializer
        @serializer.converter_factory.register Synapse::Serialization::OrderedHashToHashConverter.new
      end

      # TODO Factor this out
      client = Mongo::MongoClient.new
      template = Synapse::EventStore::Mongo::DefaultMongoTemplate.new client

      upcaster_chain = Synapse::Upcasting::UpcasterChain.new @serializer.converter_factory

      strategy = Synapse::EventStore::Mongo::DocumentPerCommitStrategy.new template, @serializer, upcaster_chain

      @event_store = Synapse::EventStore::Mongo::MongoEventStore.new template, strategy
      @event_store.ensure_indexes
    end

    def with_snapshotting
      taker = Synapse::EventSourcing::AggregateSnapshotTaker.new @event_store
      taker.register_factory @aggregate_factory
      @snapshot_trigger = Synapse::EventSourcing::EventCountSnapshotTrigger.new taker, @infrastructure.unit_provider
    end
  end
end
