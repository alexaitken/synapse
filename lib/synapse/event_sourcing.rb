module Synapse
  module EventSourcing
    extend ActiveSupport::Autoload

    eager_autoload do
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

      autoload_at 'synapse/event_sourcing/conflict_resolver' do
        autoload :ConflictResolver
        autoload :ConflictResolvingUnitOfWorkListener
        autoload :CapturingEventStream
      end

      autoload_at 'synapse/event_sourcing/snapshot/taker' do
        autoload :AggregateSnapshotTaker
        autoload :DeferredSnapshotTaker
        autoload :SnapshotTaker
      end

      autoload_at 'synapse/event_sourcing/snapshot/count_stream' do
        autoload :CountingEventStream
        autoload :TriggeringEventStream
        autoload :SnapshotUnitOfWorkListener
      end

      autoload :EventCountSnapshotTrigger, 'synapse/event_sourcing/snapshot/count_trigger'
    end
  end
end
