module Synapse
  module EventSourcing
    # Implementation of a snapshot policy that is based on the number of events committed in an
    # aggregate since the last snapshot
    class IntervalSnapshotPolicy < SnapshotPolicy
      # @param [Integer] threshold
      # @return [undefined]
      def initialize(threshold)
        @threshold = threshold
      end

      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      def should_snapshot?(aggregate)
        (aggregate.version - (aggregate.initial_version || 0)) >= @threshold
      end
    end # IntervalSnapshotPolicy
  end # EventSourcing
end
