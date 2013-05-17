module Synapse
  module Repository
    # Simple repository that works with all sorts of different object mappers, including:
    #
    # - ActiveRecord
    # - DataMapper
    # - Mongoid
    # - MongoMapper
    #
    # The only requirement of the model is that it expose the version field.
    class SimpleRepository < LockingRepository
      # @param [LockManager] lock_manager
      # @param [Class] aggregate_type
      # @return [undefined]
      def initialize(lock_manager, aggregate_type)
        super lock_manager

        @aggregate_type = aggregate_type
        @storage_listener = SimpleStorageListener.new
      end

    protected

      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version
      # @return [AggregateRoot]
      def perform_load(aggregate_id, expected_version)
        aggregate = @aggregate_type.find aggregate_id
        aggregate.tap do
          unless aggregate
            raise AggregateNotFoundError
          end

          assert_version_expected aggregate, expected_version
        end
      end

      # @return [Class]
      def aggregate_type
        @aggregate_type
      end

      # @return [StorageListener]
      def storage_listener
        @storage_listener
      end
    end # SimpleRepository

    class SimpleStorageListener < UnitOfWork::StorageListener
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def store(aggregate)
        if aggregate.deleted?
          aggregate.destroy
        else
          aggregate.version = (aggregate.version or 0).next
          aggregate.save
        end
      end
    end # SimpleStorageListener
  end
end
