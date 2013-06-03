module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures an event sourcing repository
      #
      # @see EventSourcingRepositoryDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def es_repository(identifier = nil, &block)
        with_definition_builder EventSourcingRepositoryDefinitionBuilder, identifier, &block
      end

      # Creates and configures an aggregate snapshot taker
      #
      # @see AggregateSnapshotTakerDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def aggregate_snapshot_taker(identifier = nil, &block)
        with_definition_builder AggregateSnapshotTakerDefinitionBuilder, identifier, &block
      end

      # Creates and configures an interval-based snapshot policy
      #
      # @see IntervalSnapshotPolicyDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def interval_snapshot_policy(identifier = nil, &block)
        with_definition_builder IntervalSnapshotPolicyDefinitionBuilder, identifier, &block
      end
    end # ContainerBuilder
  end # Configuration
end
