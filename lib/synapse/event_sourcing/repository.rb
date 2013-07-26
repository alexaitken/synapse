module Synapse
  module EventSourcing
    # Repository that initializes the state of aggregates using events read from an event
    # store and appends changes to aggregates to an event store
    class EventSourcingRepository < Repository::LockingRepository
      # @return [AggregateFactory]
      attr_reader :aggregate_factory

      # @return [ConflictResolver]
      attr_accessor :conflict_resolver

      # @return [EventStore]
      attr_reader :event_store

      # @return [SnapshotPolicy]
      attr_accessor :snapshot_policy

      # @return [SnapshotTaker]
      attr_accessor :snapshot_taker

      # @param [AggregateFactory] aggregate_factory
      # @param [EventStore] event_store
      # @param [LockManager] lock_manager
      # @return [undefined]
      def initialize(aggregate_factory, event_store, lock_manager)
        super lock_manager

        @aggregate_factory = aggregate_factory
        @event_store = event_store
        # TODO This should be a thread-safe structure
        @stream_decorators = Array.new
      end

      # @param [EventStreamDecorator] decorator
      # @return [undefined]
      def add_stream_decorator(decorator)
        @stream_decorators.push decorator
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
          stream = @event_store.read_events type_identifier, aggregate_id
        rescue EventStore::StreamNotFoundError
          raise Repository::AggregateNotFoundError
        end

        stream = decorate_stream_for_read aggregate_id, stream

        aggregate = @aggregate_factory.create_aggregate aggregate_id, stream.peek

        stream = add_conflict_resolution stream, aggregate, expected_version

        aggregate.initialize_from_stream stream

        if aggregate.deleted?
          raise AggregateDeletedError.new type_identifier, aggregate_id
        end

        if expected_version && @conflict_resolver.nil?
          assert_version_expected aggregate, expected_version
        end

        aggregate
      end

      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def post_registration(aggregate)
        if @snapshot_policy && @snapshot_taker
          listener =
            SnapshotUnitOfWorkListener.new type_identifier, aggregate, @snapshot_policy, @snapshot_taker

          register_listener listener
        end
      end

      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def delete_aggregate_with_lock(aggregate)
        save_aggregate_with_lock aggregate
      end

      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def save_aggregate_with_lock(aggregate)
        stream = aggregate.uncommitted_events
        stream = decorate_stream_for_append aggregate, stream

        @event_store.append_events type_identifier, stream
        aggregate.mark_committed
      end

      # @return [Class]
      def aggregate_type
        @aggregate_factory.aggregate_type
      end

      # @return [String]
      def type_identifier
        @aggregate_factory.type_identifier
      end

      private

      # @param [Object] aggregate_id
      # @param [DomainEventStream] stream
      # @return [DomainEventStream]
      def decorate_stream_for_read(aggregate_id, stream)
        @stream_decorators.each do |decorator|
          stream = decorator.decorate_for_read aggregate_type, aggregate_id, stream
        end

        stream
      end

      # @param [AggregateRoot] aggregate
      # @param [DomainEventStream] stream
      # @return [DomainEventStream]
      def decorate_stream_for_append(aggregate, stream)
        @stream_decorators.reverse_each do |decorator|
          stream = decorator.decreate_for_append type_identifier, aggregate, stream
        end
      end

      # @param [DomainEventStream] stream
      # @param [AggregateRoot] aggregate
      # @param [Integer] expected_version
      # @return [DomainEventStream]
      def add_conflict_resolution(stream, aggregate, expected_version)
        unless expected_version && @conflict_resolver
          return stream
        end

        unseen_events = Array.new

        stream = CapturingEventStream.new stream, unseen_events, expected_version
        listener = ConflictResolvingUnitOfWorkListener.new aggregate, unseen_events, @conflict_resolver

        register_listener listener

        stream
      end
    end # EventSourcingRepository

    # Raised when an aggregate has been found but it was marked for deletion
    class AggregateDeletedError < Repository::AggregateNotFoundError
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @return [undefined]
      def initialize(type_identifier, aggregate_id)
        super "Aggregate {#{type_identifier}} {#{aggregate_id}} has been marked for deletion"
      end
    end # AggregateDeletedError
  end # EventSourcing
end
