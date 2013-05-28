module Synapse
  module Configuration
    # Definition builder used to create event sourced aggregate repositories
    #
    # @example The minimum possible effort to build a event sourcing repository
    #   es_repository :orderbook_repository do
    #     use_aggregate_type TradeEngine::OrderBook
    #   end
    class EventSourcingRepositoryDefinitionBuilder < LockingRepositoryDefinitionBuilder
      # Convenience method that defines an aggregate factory capable of creating aggregates 
      # of the given type
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

    protected

      # @return [undefined]
      def populate_defaults
        super

        use_event_store :event_store

        use_factory do
          aggregate_factory = resolve @aggregate_factory
          event_store = resolve @event_store
          lock_manager = build_lock_manager

          repository = EventSourcing::EventSourcingRepository.new aggregate_factory, event_store, lock_manager
          inject_base_dependencies repository
        end
      end
    end # EventSourcingRepositoryDefinitionBuilder
  end # Configuration
end
