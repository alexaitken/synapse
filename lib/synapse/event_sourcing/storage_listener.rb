module Synapse
  module EventSourcing
    # Storage listener that commits aggregates to an event store
    class EventSourcedStorageListener < UnitOfWork::StorageListener
      # @param [EventStore] event_store
      # @param [LockManager] lock_manager
      # @param [Array] stream_decorators
      # @param [String] type_identifier
      # @return [undefined]
      def initialize(event_store, lock_manager, stream_decorators, type_identifier)
        @event_store = event_store
        @lock_manager = lock_manager
        @stream_decorators = stream_decorators
        @type_identifier = type_identifier
      end

      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def store(aggregate)
        if aggregate.version and !@lock_manager.validate_lock aggregate
          raise Repository::ConflictingModificationError
        end

        stream = aggregate.uncommitted_events
        @stream_decorators.reverse_each do |decorator|
          stream = decorator.decorate_for_append @type_identifier, aggregate, stream
        end

        @event_store.append_events @type_identifier, stream
        aggregate.mark_committed
      end
    end
  end
end
