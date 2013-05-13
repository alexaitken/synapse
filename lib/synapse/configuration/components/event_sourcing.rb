module Synapse
  module Configuration
    class ContainerBuilder
      # @yield [EventSourcingRepositoryDefintionBuilder]
      # @return [undefined]
      def event_sourcing(&block)
        with_builder EventSourcingRepositoryDefintionBuilder, &block
      end
    end

    # @todo Add snapshot DSL
    # @todo Add conflict resolution DSL
    #
    # @example
    #   event_sourcing do |es|
    #     # Minimum required to build an event sourcing repository
    #     es.id = :orderbook_repository
    #     es.for_aggregate TradeEngine::Orderbook
    #   end
    class EventSourcingRepositoryDefintionBuilder < ServiceDefinitionBuilder
      # @return [Symbol]
      attr_accessor :aggregate_factory
      # @return [Symbol] Event bus to publish aggregate events to
      attr_accessor :event_bus
      # @return [Symbol] Event store to read and append events
      attr_accessor :event_store
      # @return [Symbol]
      attr_accessor :lock_manager
      # @return [Symbol]
      attr_accessor :unit_provider

      # @param [Class] type
      # @return [undefined]
      def for_aggregate(type)
        @aggregate_factory = EventSourcing::GenericAggregateFactory.new type
      end

      # Changes the lock manager to use optimistic locking
      # @return [undefined]
      def with_optimistic_locking
        @lock_manager = Repository::OptimisticLockManager.new
      end

      # Changes the lock manager to use no locking
      # @return [undefined]
      def with_no_locking
        @lock_manager = Repository::NullLockManager.new
      end

    protected

      # @return [undefined]
      def populate_defaults
        @event_bus = :event_bus
        @event_store = :event_store
        @lock_manager = Repository::PessimisticLockManager.new
        @unit_provider = :unit_provider

        with_factory do |container|
          aggregate_factory = resolve @aggregate_factory
          event_store = resolve @event_store
          lock_manager = resolve @lock_manager

          repository = EventSourcing::EventSourcingRepository.new aggregate_factory, event_store, lock_manager
          repository.tap do
            repository.event_bus = resolve @event_bus
            repository.unit_provider = resolve @unit_provider
          end
        end
      end
    end # EventSourcingRepositoryDefintionBuilder
  end # Configuration
end
