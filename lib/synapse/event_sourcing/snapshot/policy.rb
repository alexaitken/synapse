module Synapse
  module EventSourcing
    # Represents a mechanism for determining if an aggregate should have a snapshot taken
    class SnapshotPolicy
      # Returns true if a snapshot should be scheduled for the given aggregate
      #
      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def should_snapshot?(aggregate); end
    end # SnapshotPolicy

    # Snapshot policy that takes a snapshot if the number of events committed in an aggregate since
    # the last snapshot goes over the configured threshold
    class IntervalSnapshotPolicy < SnapshotPolicy
      # @param [Integer] threshold
      # @return [undefined]
      def initialize(threshold)
        @threshold = threshold
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def should_snapshot?(aggregate)
        (aggregate.version - (aggregate.initial_version or 0)) >= @threshold
      end
    end # IntervalSnapshotPolicy
  end # EventSourcing
end
