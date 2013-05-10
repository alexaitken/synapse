module Synapse
  module EventSourcing
    # Represents a mechanism for creating snapshot events for aggregates
    #
    # Implementations can choose whether to snapshot the aggregate in the calling thread or
    # asynchronously, though it is typically done asynchronously.
    #
    # @abstract
    class SnapshotTaker
      # Schedules a snapshot to be taken for an aggregate of the given type and with the given
      # identifier
      #
      # @abstract
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @return [undefined]
      def schedule_snapshot(type_identifier, aggregate_id); end
    end

    # Snapshot taker that uses the actual aggregate and its state to create a snapshot event
    class AggregateSnapshotTaker < SnapshotTaker
      # @param [SnapshotEventStore] event_store
      # @return [undefined]
      def initialize(event_store)
        @aggregate_factories = Hash.new
        @event_store = event_store
      end

      # @param [AggregateFactory] factory
      # @return [undefined]
      def register_factory(factory)
        @aggregate_factories.store factory.type_identifier, factory
      end

      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @return [undefined]
      def schedule_snapshot(type_identifier, aggregate_id)
        stream = @event_store.read_events type_identifier, aggregate_id
        factory = @aggregate_factories.fetch type_identifier

        aggregate = factory.create_aggregate aggregate_id, stream.peek
        aggregate.initialize_from_stream stream

        snapshot = Domain::DomainEventMessage.build do |builder|
          builder.payload = aggregate
          builder.aggregate_id = aggregate.id
          builder.sequence_number = aggregate.version
        end

        @event_store.append_snapshot_event type_identifier, snapshot
      end
    end
  end
end
