module Synapse
  module Persistence
    # Represents a mechanism for locking aggregates for modification
    class LockManager
      include AbstractType

      # Ensures that the current thread holds a valid lock for the given aggregate
      #
      # @param [AggregateRoot] aggregate
      # @return [Boolean]
      abstract_method :validate_lock

      # Obtains a lock for an aggregate with the given aggregate identifier. Depending on
      # the strategy, this method may return immediately or block until a lock is held.
      #
      # @param [Object] aggregate_id
      # @return [undefined]
      abstract_method :obtain_lock

      # Releases the lock held for an aggregate with the given aggregate identifier. The caller
      # of this method must ensure a valid lock was requested using {#obtain_lock}. If no lock
      # was successfully obtained, the behavior of this method is undefined.
      #
      # @param [Object] aggregate_id
      # @return [undefined]
      abstract_method :release_lock
    end # LockManager
  end # Persistence
end
