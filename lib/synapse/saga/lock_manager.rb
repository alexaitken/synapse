module Synapse
  module Saga
    # Represents a mechanism for synchronizing access to sagas
    class LockManager
      include AbstractType

      # Obtains a lock for a saga with the given identifier, blocking if necessary
      #
      # @param [String] saga_id
      # @return [undefined]
      abstract_method :obtain_lock

      # Releases the lock for a saga with the given identifier
      #
      # @raise [ThreadError] If thread didn't previously hold the lock
      # @param [String] saga_id
      # @return [undefined]
      abstract_method :release_lock
    end # LockManager
  end # Saga
end
