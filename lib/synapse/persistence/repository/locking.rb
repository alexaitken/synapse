module Synapse
  module Persistence
    # Partial implementation of a repository that handles integration with a lock manager
    class LockingRepository < Repository
      include AbstractType
      include Loggable

      # @param [LockManager] lock_manager
      # @return [undefined]
      def initialize(lock_manager)
        @lock_manager = lock_manager
      end

      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version If this is nil, no version validation is performed
      # @return [AggregateRoot]
      def load(aggregate_id, expected_version = nil)
        @lock_manager.obtain_lock aggregate_id

        begin
          aggregate = perform_load aggregate_id, expected_version

          register_aggregate aggregate
          register_unit_listener LockCleaningUnitListener.new aggregate_id, @lock_manager

          post_registration aggregate

          aggregate
        rescue
          logger.debug 'Exception occured while loading aggregate -- releasing lock'

          @lock_manager.release_lock aggregate_id
          raise
        end
      end

      # @raise [ArgumentError] If the aggregate has a version
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def add(aggregate)
        @lock_manager.obtain_lock aggregate.id

        begin
          ensure_compatible aggregate

          register_aggregate aggregate
          register_unit_listener LockCleaningUnitListener.new aggregate.id, @lock_manager

          post_registration aggregate
        rescue
          logger.debug 'Exception occured while adding aggregate -- releasing lock'

          @lock_manager.release_lock aggregate.id
          raise
        end
      end

      protected

      # Fetches the aggregate with the given identifier from the underlying aggregate store
      #
      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version
      # @return [AggregateRoot]
      abstract_method :perform_load

      # Deletes the given aggregate from the underlying storage mechanism, ensuring that the lock
      # for the aggregate is valid before doing so
      #
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      abstract_method :delete_aggregate_with_lock

      # Saves the given aggregate using the underlying storage mechanism, ensuring that the lock
      # for the aggregate is valid before doing so
      #
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      abstract_method :save_aggregate_with_lock

      # Hook that is called after an aggregate is registered to the current unit of work
      #
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def post_registration(aggregate); end

      # @raise [ConcurrencyError] If aggregate is versioned and its lock has been invalidated by
      #   the lock manager
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def delete_aggregate(aggregate)
        ensure_valid_lock aggregate
        delete_aggregate_with_lock aggregate
      end

      # @raise [ConcurrencyError] If aggregate is versioned and its lock has been invalidated by
      #   the lock manager
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def save_aggregate(aggregate)
        ensure_valid_lock aggregate
        save_aggregate_with_lock aggregate
      end

      # @raise [ConcurrencyError] If aggregate is versioned and its lock has been invalidated by
      #   the lock manager
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def ensure_valid_lock(aggregate)
        # The aggregate is new, no need to validate our lock
        return unless aggregate.version

        unless @lock_manager.validate_lock aggregate
          raise ConcurrencyError
        end
      end
    end # LockingRepository

    # Unit of work listener that releases the lock on an aggregate when the unit of work
    # is cleaning up
    class LockCleaningUnitListener
      include UnitOfWork::UnitListener

      # @param [Object] aggregate_id
      # @param [LockManager] lock_manager
      # @return [undefined]
      def initialize(aggregate_id, lock_manager)
        @aggregate_id = aggregate_id
        @lock_manager = lock_manager
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_cleanup(unit)
        @lock_manager.release_lock @aggregate_id
      end
    end # LockCleaningUnitListener
  end # Persistence
end
