module Synapse
  module Configuration
    # Definition builder used to create aggregate snapshot takers
    #
    # @example The minimum possible effort to build an aggregate snapshot taker
    #   aggregate_snapshot_taker
    #
    # @example Build an aggregate snapshot taker using an alternate event store and factory tag
    #   aggregate_snapshot_taker :alt_snapshot_taker do
    #     use_aggregate_factory_tag :alt_factory_tag
    #     use_event_store :alt_event_store
    #   end
    class AggregateSnapshotTakerDefinitionBuilder < DefinitionBuilder
      # Changes the tag used to find aggregate factories necessary for creating aggregates so that
      # a snapshot can be taken of their current state
      #
      # @see EventSourcing::AggregateFactory
      # @param [Symbol] aggregate_factory_tag
      # @return [undefined]
      def use_aggregate_factory_tag(aggregate_factory_tag)
        @aggregate_factory_tag = aggregate_factory_tag
      end

      # Changes the event store used to load and store aggregates
      #
      # @see EventStore::SnapshotEventStore
      # @param [Symbol] event_store
      # @return [undefined]
      def use_event_store(event_store)
        @event_store = event_store
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :snapshot_taker

        use_aggregate_factory_tag :aggregate_factory
        use_event_store :event_store

        use_factory do
          event_store = resolve @event_store
          snapshot_taker = EventSourcing::AggregateSnapshotTaker.new event_store

          with_tagged @aggregate_factory_tag do |factory|
            snapshot_taker.register_factory factory
          end

          snapshot_taker
        end
      end
    end # AggregateSnapshotTakerDefinitionBuilder
  end # Configuration
end
