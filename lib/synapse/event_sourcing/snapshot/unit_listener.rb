module Synapse
  module EventSourcing
    # Unit of work listener that schedules snapshots
    class SnapshotUnitOfWorkListener < UnitOfWork::UnitOfWorkListener
      # @param [String] type_identifier
      # @param [AggregateRoot] aggregate
      # @param [SnapshotPolicy] policy
      # @param [SnapshotTaker] taker
      # @return [undefined]
      def initialize(type_identifier, aggregate, policy, taker)
        @type_identifier = type_identifier
        @aggregate = aggregate
        @policy = policy
        @taker = taker
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_cleanup(unit)
        if @policy.should_snapshot? @aggregate
          @taker.schedule_snapshot @type_identifier, @aggregate.id
        end
      end
    end # SnapshotUnitOfWorkListener
  end # EventSourcing
end
