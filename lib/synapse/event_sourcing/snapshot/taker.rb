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
    end # SnapshotTaker
  end # EventSourcing
end
