module Synapse
  module EventStore
    # Represents a mechanism for reading and appending streams of domain events
    # @abstract
    class EventStore
      # Fetches an event stream for the aggregate identified by the given type identifier and
      # the given aggregate identifier. This stream can be used to rebuild the state of the
      # aggregate.
      #
      # Implementations may omit or replace events (for example, with snapshot events) from the
      # stream for performance purposes.
      #
      # @abstract
      # @raise [EventStoreError] If an error occurs while reading the stream from the store
      # @param [String] type_identifier Type descriptor of the aggregate to retrieve
      # @param [Object] aggregate_id
      # @return [DomainEventStream]
      def read_events(type_identifier, aggregate_id); end

      # Appends the domain events in the given stream to the event store
      #
      # @abstract
      # @raise [EventStoreError] If an error occurs while appending the stream to the store
      # @param [String] type_identifier Type descriptor of the aggregate to append to
      # @param [DomainEventStream] stream
      # @return [undefined]
      def append_events(type_identifier, stream); end
    end

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
      def append_snapshot_event(type_identifier, snapshot_event); end
    end
  end
end
