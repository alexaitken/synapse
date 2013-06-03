module Synapse
  module Configuration
    # Definition builder that serves a base for building specific implementations of a
    # locking repository
    #
    # @abstract
    # @see EventSourcingRepositoryDefinitionBuilder
    # @see SimpleRepositoryDefinitionBuilder
    class LockingRepositoryDefinitionBuilder < DefinitionBuilder
      # Changes the event bus used to publish aggregate events to
      #
      # @see EventBus::EventBus
      # @param [Symbol] event_bus
      # @return [undefined]
      def use_event_bus(event_bus)
        @event_bus = event_bus
      end

      # Uses the lock manager with no locking
      #
      # @see Repository::NullLockManager
      # @return [undefined]
      def use_no_locking
        @lock_manager_type = Repository::NullLockManager
      end

      # Uses the lock manager with pessimistic locking
      #
      # @see Repository::PessimisticLockManager
      # @return [undefined]
      def use_pessimistic_locking
        @lock_manager_type = Repository::PessimisticLockManager
      end

      # Uses the lock manager with optimistic locking
      #
      # @see Repository::OptimisticLockManager
      # @return [undefined]
      def use_optimistic_locking
        @lock_manager_type = Repository::OptimisticLockManager
      end

      # Changes the lock manager used to prevent concurrent aggregate modification
      #
      # @see Repository::LockManager
      # @param [Symbol] lock_manager
      # @return [undefined]
      def use_lock_manager(lock_manager)
        @lock_manager = lock_manager
      end

      # Changes the provider used to get the current unit of work
      #
      # @see UnitOfWork::UnitOfWorkProvider
      # @param [Symbol] unit_provider
      # @return [undefined]
      def use_unit_provider(unit_provider)
        @unit_provider = unit_provider
      end

    protected

      # @return [undefined]
      def populate_defaults
        use_event_bus :event_bus
        use_pessimistic_locking
        use_unit_provider :unit_provider
      end

      # @raise [RuntimeError] If no lock manager was configured
      # @return [LockManager]
      def build_lock_manager
        if @lock_manager
          resolve @lock_manager
        elsif @lock_manager_type
          @lock_manager_type.new
        else
          raise 'No lock manager was configured for this repository'
        end
      end

      # Injects the dependencies required by the base repository class
      #
      # @param [Repository] repository
      # @return [Repository]
      def inject_base_dependencies(repository)
        repository.event_bus = resolve @event_bus
        repository.unit_provider = resolve @unit_provider

        repository
      end
    end # LockingRepositoryDefinitionBuilder
  end # Configuration
end
