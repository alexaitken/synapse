module Synapse
  module EventSourcing
    # Implementation of an event sourcing repository that uses a cache to improve performance when
    # loading aggregates
    #
    # Caching is not compatible with optimistic locking
    #
    # Note that if an error occurs while saving an aggregate, it will be invalidated from the cache
    # to prevent aggregates being returned from the cache that were not fully persisted to disk.
    class CachingEventSourcingRepository < EventSourcingRepository
      # @todo This should be a ctor parameter
      # @return [ActiveSupport::Cache::Store]
      attr_accessor :cache

      protected

      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [AggregateDeletedError]
      #   If the loaded aggregate has been marked as deleted
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version
      # @return [AggregateRoot]
      def perform_load(aggregate_id, expected_version)
        aggregate = @cache.fetch aggregate_id

        if aggregate.nil?
          aggregate = super aggregate_id, expected_version
        elsif aggregate.deleted?
          raise AggregateDeletedError.new type_identifier, aggregate_id
        end

        register_listener CacheClearingUnitOfWorkListener.new aggregate_id, @cache

        aggregate
      end

      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def save_aggregate_with_lock(aggregate)
        super aggregate
        @cache.write aggregate.id, aggregate
      end
    end # CachingEventSourcingRepository

    # Listener that removes an aggregate from the cache if the unit of work is rolled back
    # @api private
    class CacheClearingUnitOfWorkListener < UnitOfWork::UnitOfWorkListener
      # @param [Object] aggregate_id
      # @param [ActiveSupport::Cache::Store] cache
      # @return [undefined]
      def initialize(aggregate_id, cache)
        @aggregate_id = aggregate_id
        @cache = cache
      end

      # @param [UnitOfWork] unit
      # @param [Error] cause
      # @return [undefined]
      def on_rollback(unit, cause = nil)
        @cache.delete @aggregate_id
      end
    end # CacheClearingUnitOfWorkListener
  end # EventSourcing
end
