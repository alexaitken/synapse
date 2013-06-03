module Synapse
  module Configuration
    # Definition builder used to create event sourced aggregate repositories
    #
    # @example The minimum possible effort to build a event sourcing repository
    #   es_repository :orderbook_repository do
    #     use_aggregate_type TradeEngine::OrderBook
    #   end
    #
    # @example Use an event sourcing repository with snapshotting capability
    #   aggregate_snapshot_taker
    #
    #   interval_snapshot_policy do
    #     use_threshold 50
    #   end
    #
    #   es_repository :orderbook_repository do
    #     use_aggregate_type TradeEngine::OrderBook
    #   end
    class EventSourcingRepositoryDefinitionBuilder < LockingRepositoryDefinitionBuilder
      # Convenience method that defines an aggregate factory capable of creating aggregates
      # of the given type
      #
      # Definitions have to be created by aggregate factories so that aggregate factories can be
      # registered to an aggregate snapshot taker.
      #
      # @param [Class] aggregate_type
      # @return [undefined]
      def use_aggregate_type(aggregate_type)
        @aggregate_factory = build_composite do
          anonymous
          tag :aggregate_factory
          use_factory do
            EventSourcing::GenericAggregateFactory.new aggregate_type
          end
        end
      end

      # @param [Symbol] aggregate_factory
      # @return [undefined]
      def use_aggregate_factory(aggregate_factory)
        @aggregate_factory = aggregate_factory
      end

      # @param [Symbol] conflict_resolver
      # @return [undefined]
      def use_conflict_resolver(conflict_resolver)
        @conflict_resolver = conflict_resolver
      end

      # @param [Symbol] event_store
      # @return [undefined]
      def use_event_store(event_store)
        @event_store = event_store
      end

      # @param [Symbol] snapshot_policy
      # @return [undefined]
      def use_snapshot_policy(snapshot_policy)
        @snapshot_policy = snapshot_policy
      end

      # @param [Symbol] snapshot_taker
      # @return [undefined]
      def use_snapshot_taker(snapshot_taker)
        @snapshot_taker = snapshot_taker
      end

    protected

      # @return [undefined]
      def populate_defaults
        super

        use_conflict_resolver :conflict_resolver
        use_event_store :event_store
        use_snapshot_policy :snapshot_policy
        use_snapshot_taker :snapshot_taker

        use_factory do
          aggregate_factory = resolve @aggregate_factory
          event_store = resolve @event_store
          lock_manager = build_lock_manager

          repository = EventSourcing::EventSourcingRepository.new aggregate_factory, event_store, lock_manager

          # Optional dependencies
          repository.conflict_resolver = resolve @conflict_resolver, true
          repository.snapshot_policy = resolve @snapshot_policy, true
          repository.snapshot_taker = resolve @snapshot_taker, true

          inject_base_dependencies repository
        end
      end
    end # EventSourcingRepositoryDefinitionBuilder
  end # Configuration
end
