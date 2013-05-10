module Synapse
  module EventStore
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload_at 'synapse/event_store/errors' do
        autoload :EventStoreError
        autoload :StreamNotFoundError
      end

      autoload_at 'synapse/event_store/event_store' do
        autoload :EventStore
        autoload :SnapshotEventStore
      end
    end

    autoload :InMemoryEventStore, 'synapse/event_store/in_memory'

    module Mongo
      extend ActiveSupport::Autoload

      autoload :CursorDomainEventStream, 'synapse/event_store/mongo/cursor_event_stream'
      autoload :MongoEventStore, 'synapse/event_store/mongo/event_store'
      autoload :DocumentPerEventStrategy, 'synapse/event_store/mongo/per_event_strategy'
      autoload :DocumentPerCommitStrategy, 'synapse/event_store/mongo/per_commit_strategy'
      autoload :StorageStrategy, 'synapse/event_store/mongo/storage_strategy'

      autoload_at 'synapse/event_store/mongo/template' do
        autoload :MongoTemplate
        autoload :DefaultMongoTemplate
      end
    end
  end
end
