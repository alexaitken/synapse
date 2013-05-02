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
    autoload :MessageBuilder
  end

  module Command
    extend ActiveSupport::Autoload

    autoload :CommandBus
    autoload :SimpleCommandBus

    autoload :CommandCallback
    autoload :CommandFilter
    autoload :CommandHandler

    autoload_at 'synapse/command/message' do
      autoload :CommandMessage
      autoload :CommandMessageBuilder
    end

    autoload :CommandGateway, 'synapse/command/gateway'

    autoload :DispatchInterceptor
    autoload :InterceptorChain

    autoload_at 'synapse/command/errors' do
      autoload :CommandExecutionError
      autoload :CommandValidationError
      autoload :NoHandlerError
    end

    autoload_at 'synapse/command/filters/validation' do
      autoload :ActiveModelValidationFilter
      autoload :ActiveModelValidationError
    end

    autoload_at 'synapse/command/rollback_policy' do
      autoload :RollbackPolicy
      autoload :RollbackOnAnyExceptionPolicy
    end
  end

  module Domain
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload_at 'synapse/domain/aggregate_root' do
        autoload :AggregateRoot
        autoload :AggregateIdentifierNotInitializedError
      end

      autoload :EventContainer

      autoload_at 'synapse/domain/message' do
        autoload :EventMessage
        autoload :DomainEventMessage
      end

      autoload_at 'synapse/domain/message_builder' do
        autoload :EventMessageBuilder
        autoload :DomainEventMessageBuilder
      end

      autoload_at 'synapse/domain/stream' do
        autoload :DomainEventStream
        autoload :EndOfStreamError
        autoload :SimpleDomainEventStream
      end
    end
  end

  module EventBus
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload_at 'synapse/event_bus/event_bus' do
        autoload :EventBus
        autoload :SubscriptionFailedError
      end

      autoload :EventListener
      autoload :EventListenerProxy
      autoload :SimpleEventBus
    end
  end

  module EventSourcing
    extend ActiveSupport::Autoload

    autoload_at 'synapse/event_sourcing/aggregate_factory' do
      autoload :AggregateFactory
      autoload :GenericAggregateFactory
    end

    autoload :AggregateRoot
    autoload :Entity
    autoload :Member

    autoload :EventSourcingRepository, 'synapse/event_sourcing/repository'
    autoload :EventSourcedStorageListener, 'synapse/event_sourcing/storage_listener'
    autoload :EventStreamDecorator, 'synapse/event_sourcing/stream_decorator'
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

    eager_autoload do
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
  end

  module Serialization
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Converter
      autoload :ConverterFactory,  'synapse/serialization/converter/factory'
      autoload :IdentityConverter, 'synapse/serialization/converter/identity'

      autoload :SerializedObjectCache, 'synapse/serialization/message/cache'
      autoload :SerializedDomainEventData, 'synapse/serialization/message/data'
      autoload :SerializedMessage, 'synapse/serialization/message/message'

      autoload_at 'synapse/serialization/message/domain' do
        autoload :SerializedEventMessage
        autoload :SerializedDomainEventMessage
      end

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

      autoload :Serializer
      autoload :SerializedObject
      autoload :SerializedType
    end

    autoload_at 'synapse/serialization/converter/json' do
      autoload :JsonToObjectConverter
      autoload :ObjectToJsonConverter
    end

    autoload_at 'synapse/serialization/converter/ox' do
      autoload :XmlToOxDocumentConverter
      autoload :OxDocumentToXmlConverter
    end

    autoload :OjSerializer, 'synapse/serialization/serializer/oj'
    autoload :OxSerializer, 'synapse/serialization/serializer/ox'
    autoload :MarshalSerializer, 'synapse/serialization/serializer/marshal'
  end

  module UnitOfWork
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload_at 'synapse/uow/nesting' do
        autoload :NestableUnitOfWork
        autoload :OuterCommitUnitOfWorkListener
      end

      autoload :StorageListener, 'synapse/uow/storage_listener'
      autoload :TransactionManager, 'synapse/uow/transaction_manager'
      autoload :UnitOfWork, 'synapse/uow/uow'
      autoload :UnitOfWorkFactory, 'synapse/uow/factory'
      autoload :UnitOfWorkListener, 'synapse/uow/listener'
      autoload :UnitOfWorkListenerCollection, 'synapse/uow/listener_collection'
      autoload :UnitOfWorkProvider, 'synapse/uow/provider'
    end
  end

  module Upcasting
    extend ActiveSupport::Autoload

    autoload :SingleUpcaster
    autoload :Upcaster
    autoload :UpcasterChain, 'synapse/upcasting/chain'
    autoload :UpcastingContext, 'synapse/upcasting/context'
  end

  ActiveSupport::Autoload.eager_autoload!

  # Setup the default identifier factory
  ActiveSupport.on_load :identifier_factory  do
    IdentifierFactory.instance = GuidIdentifierFactory.new
  end
end
