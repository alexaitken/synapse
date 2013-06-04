module Synapse
  module EventSourcing
    # Represents a mechanism for creating snapshot events for aggregates
    #
    # Implementations can choose whether to snapshot the aggregate in the calling thread or
    # asynchronously, though it is typically done asynchronously.
    #
    # @abstract
    class SnapshotTaker
      # @return [SnapshotEventStore]
      attr_accessor :event_store

      # @return [Executor]
      attr_accessor :executor

      # @return [undefined]
      def initialize
        @executor = DirectExecutor.new
      end

      # Schedules a snapshot to be taken for an aggregate of the given type and with the given
      # identifier
      #
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @return [undefined]
      def schedule_snapshot(type_identifier, aggregate_id)
        @executor.execute do
          stream = @event_store.read_events type_identifier, aggregate_id
          first_sequence_number = stream.peek.sequence_number
          snapshot = create_snapshot type_identifier, aggregate_id, stream

          if snapshot and snapshot.sequence_number > first_sequence_number
            @event_store.append_snapshot_event type_identifier, snapshot
          end
        end
      end

    protected

      # @abstract
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @param [DomainEventStream] stream
      # @return [DomainEventMessage]
      def create_snapshot(type_identifier, aggregate_id, stream); end
    end # SnapshotTaker
  end # EventSourcing
end
