module Synapse
  module EventSourcing
    # Represents a mechanism for determining if an aggregate should have a snapshot taken
    class SnapshotPolicy
      include AbstractType

      # Returns true if a snapshot should be scheduled for the given aggregate
      #
      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      abstract_method :should_snapshot?
    end # SnapshotPolicy
  end # EventSourcing
end
