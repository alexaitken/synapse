module Synapse
  module EventStore
    # Represents an event store with the capability to manage aggregate snapshots
    class SnapshotEventStore < EventStore
      include AbstractType

      # Appends the given snapshot event to the event store
      #
      # @raise [EventStoreError] If an error occurs while appending the event to the store
      # @param [String] type_identifier Type descriptor of the aggregate to append to
      # @param [DomainEventMessage] snapshot_event
      # @return [undefined]
      abstract_method :append_snapshot_event
    end # SnapshotEventStore
  end # EventStore
end
