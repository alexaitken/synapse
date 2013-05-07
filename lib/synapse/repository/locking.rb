module Synapse
  module Repository
    # Partial implementation of a repository that handles integration with a lock manager
    # @abstract
    class LockingRepository < Repository
      # @return [LockManager]
      attr_reader :lock_manager

      def initialize(lock_manager)
        @lock_manager = lock_manager
        @logger = Logging.logger.new self.class
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

          aggregate = register_aggregate aggregate
          register_listener LockCleaningUnitOfWorkListener.new aggregate_id, @lock_manager

          aggregate
        rescue
          @logger.debug 'Excepton raised while loading an aggregate, releasing lock'

          @lock_manager.release_lock aggregate_id
          raise
        end
      end

      # @raise [ArgumentError] If the version of the aggregate is not null
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def add(aggregate)
        @lock_manager.obtain_lock aggregate.id

        begin
          assert_compatible aggregate

          register_aggregate aggregate
          register_listener LockCleaningUnitOfWorkListener.new aggregate.id, @lock_manager
        rescue
          @logger.debug 'Exception raised while adding an aggregate, releasing lock'

          @lock_manager.release_lock aggregate.id
          raise
        end
      end

    protected

      # Fetches the aggregate with the given identifier from the underlying aggregate store
      #
      # @abstract
      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version
      # @return [AggregateRoot]
      def perform_load(aggregate_id, expected_version); end

      def logger

      end
    end

    # Unit of work listener that releases the lock on an aggregate when the unit of work
    # is cleaning up
    class LockCleaningUnitOfWorkListener < UnitOfWork::UnitOfWorkListener
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
    end
  end
end
