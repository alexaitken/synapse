require 'synapse/configuration/component/event_sourcing/snapshot/aggregate_taker'
require 'synapse/configuration/component/event_sourcing/snapshot/interval_policy'
require 'synapse/configuration/component/event_sourcing/repository'

module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures an event sourcing repository
      builder :es_repository, EventSourcingRepositoryDefinitionBuilder

      # Creates and configures an aggregate snapshot taker
      builder :snapshot_taker, AggregateSnapshotTakerDefinitionBuilder

      # Creates and configures an interval-based snapshot policy
      builder :interval_snapshot_policy, IntervalSnapshotPolicyDefinitionBuilder
    end # ContainerBuilder
  end # Configuration
end
