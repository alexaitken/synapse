module Synapse
  module Saga
    # Represents a mechanism for synchronizing access to sagas
    #
    # This base implementation does no locking; it can be used if sagas are thread safe
    # and don't need any additional synchronization.
    class LockManager
      # Obtains a lock for a saga with the given identifier, blocking if necessary
      #
      # @param [String] saga_id
      # @return [undefined]
      def obtain_lock(saga_id); end

      # Releases the lock for a saga with the given identifier
      #
      # @raise [ThreadError] If thread didn't previously hold the lock
      # @param [String] saga_id
      # @return [undefined]
      def release_lock(saga_id); end
    end # LockManager
  end # Saga
end
