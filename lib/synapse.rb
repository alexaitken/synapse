require 'active_support'
require 'active_support/core_ext'
require 'logging'
require 'set'

require 'synapse/version'

module Synapse
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload_at 'synapse/errors' do
      autoload :SynapseError
      autoload :ConfigurationError
      autoload :NonTransientError
      autoload :TransientError
    end

    autoload_at 'synapse/identifier' do
      autoload :IdentifierFactory
      autoload :GuidIdentifierFactory
    end

    autoload :Message
  end

  module Domain
    extend ActiveSupport::Autoload

    autoload_at 'synapse/domain/aggregate_root' do
      autoload :AggregateRoot
      autoload :AggregateIdentifierNotInitializedError
    end

    autoload :EventContainer

    autoload_at 'synapse/domain/message' do
      autoload :EventMessage
      autoload :DomainEventMessage
    end

    autoload_at 'synapse/domain/stream' do
      autoload :DomainEventStream
      autoload :EndOfStreamError
      autoload :SimpleDomainEventStream
    end
  end

  module EventHandling
    extend ActiveSupport::Autoload

    autoload_at 'synapse/event_handling/event_bus' do
      autoload :EventBus
      autoload :SubscriptionFailedError
    end

    autoload :EventListener
    autoload :SimpleEventBus
  end

  module EventStore
    extend ActiveSupport::Autoload

    autoload_at 'synapse/event_store/errors' do
      autoload :EventStoreError
      autoload :StreamNotFoundError
    end

    autoload_at 'synapse/event_store/event_store' do
      autoload :EventStore
      autoload :SnapshotEventStore
    end

    autoload :InMemoryEventStore, 'synapse/event_store/in_memory'
  end

  module Repository
    extend ActiveSupport::Autoload

    autoload_at 'synapse/repository/errors' do
      autoload :AggregateNotFoundError
      autoload :ConcurrencyError
      autoload :ConflictingAggregateVersionError
      autoload :ConflictingModificationError
    end

    autoload :LockManager

    autoload_at 'synapse/repository/locking' do
      autoload :LockingRepository
      autoload :LockCleaningUnitOfWorkListener
    end

    autoload :Repository
  end

  module Serialization
    extend ActiveSupport::Autoload

    autoload :Converter
    autoload :ConverterFactory,  'synapse/serialization/converter/factory'
    autoload :IdentityConverter, 'synapse/serialization/converter/identity'

    autoload_at 'synapse/serialization/converter/json' do
      autoload :JsonToObjectConverter
      autoload :ObjectToJsonConverter
    end

    autoload_at 'synapse/serialization/converter/ox' do
      autoload :XmlToOxDocumentConverter
      autoload :OxDocumentToXmlConverter
    end

    autoload :SerializedDomainEventData, 'synapse/serialization/message/data'

    autoload_at 'synapse/serialization/errors' do
      autoload :ConversionError
      autoload :SerializationError
      autoload :UnknownSerializedTypeError
    end

    autoload_at 'synapse/serialization/lazy_object' do
      autoload :DeserializedObject
      autoload :LazyObject
    end

    autoload_at 'synapse/serialization/revision_resolver' do
      autoload :RevisionResolver
      autoload :FixedRevisionResolver
    end

    autoload :OjSerializer,      'synapse/serialization/serializer/oj'
    autoload :OxSerializer,      'synapse/serialization/serializer/ox'
    autoload :MarshalSerializer, 'synapse/serialization/serializer/marshal'

    autoload :Serializer
    autoload :SerializedObject
    autoload :SerializedType
  end

  module UnitOfWork
    extend ActiveSupport::Autoload

    autoload_at 'synapse/uow/nesting' do
      autoload :NestableUnitOfWork
      autoload :OuterCommitUnitOfWorkListener
    end

    autoload :AggregateStorageListener,     'synapse/uow/storage_listener'
    autoload :TransactionManager
    autoload :UnitOfWork,                   'synapse/uow/uow'
    autoload :UnitOfWorkFactory,            'synapse/uow/factory'
    autoload :UnitOfWorkListener,           'synapse/uow/listener'
    autoload :UnitOfWorkListenerCollection, 'synapse/uow/listener_collection'
    autoload :UnitOfWorkProvider,           'synapse/uow/provider'
  end

  module Upcasting
    extend ActiveSupport::Autoload

    autoload :SingleUpcaster
    autoload :Upcaster
    autoload :UpcasterChain, 'synapse/upcasting/chain'
    autoload :UpcastingContext, 'synapse/upcasting/context'
  end

  # Setup the default identifier factory
  ActiveSupport.on_load :identifier_factory  do
    IdentifierFactory.instance = GuidIdentifierFactory.new
  end
end
