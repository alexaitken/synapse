module Synapse
  module EventStore
    # Represents an event store with the capability to manage aggregate snapshots
    # @abstract
    class SnapshotEventStore < EventStore
      # Appends the given snapshot event to the event store
      #
      # @abstract
      # @raise [EventStoreError] If an error occurs while appending the event to the store
      # @param [String] type_identifier Type descriptor of the aggregate to append to
      # @param [DomainEventMessage] snapshot_event
      # @return [undefined]
      def append_snapshot_event(type_identifier, snapshot_event)
        raise NotImplementedError
      end
    end # SnapshotEventStore
  end # EventStore
end
