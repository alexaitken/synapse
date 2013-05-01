module Synapse
  module EventSourcing
    # Repository that initializes the state of aggregates using events read from an event
    # store and appends changes to aggregates to an event store
    class EventSourcingRepository < Repository::LockingRepository
      # @return [AggregateFactory]
      attr_reader :aggregate_factory

      # @return [EventStore]
      attr_reader :event_store

      # @param [AggregateFactory] aggregate_factory
      # @param [EventStore] event_store
      # @return [undefined]
      def initialize(aggregate_factory, event_store)
        @aggregate_factory = aggregate_factory
        @event_store = event_store
        @stream_decorators = Array.new
      end

      # Appends a stream decorator onto the end of the list of stream decorators
      #
      # @param [EventStreamDecorator] stream_decorator
      # @return [undefined]
      def add_stream_decorator(stream_decorator)
        @stream_decorators.push stream_decorator
      end

    protected

      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [AggregateDeletedError]
      #   If the loaded aggregate has been marked as deleted
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version
      # @return [AggregateRoot]
      def perform_load(aggregate_id, expected_version)
        begin
          stream = @event_store.read type_identifier, aggregate_id
        rescue EventStore::StreamNotFoundError
          raise Repository::AggregateNotFoundError
        end

        @stream_decorators.each do |decorator|
          stream = decorator.decorate_for_read aggregate_type, aggregate_id, stream
        end

        aggregate = @aggregate_factory.create_aggregate aggregate_id, stream.peek
        aggregate.initialize_from_stream stream

        if aggregate.deleted?
          raise AggregateDeletedError
        end

        assert_version_expected aggregate, expected_version

        aggregate
      end

      # @return [Class]
      def aggregate_type
        @aggregate_factory.aggregate_type
      end

      # @return [StorageListener]
      def storage_listener
        @storage_listener ||=
          EventSourcedStorageListener.new @event_store, @lock_manager, @stream_decorators, type_identifier
      end

      # @return [String]
      def type_identifier
        @aggregate_factory.type_identifier
      end
    end

    # Raised when an aggregate has been found but it was marked for deletion
    class AggregateDeletedError < Repository::AggregateNotFoundError; end
  end
end