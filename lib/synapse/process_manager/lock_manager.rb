module Synapse
  module ProcessManager
    # Represents a mechanism for synchronizing access to processes
    #
    # This base implementation does no locking; it can be used if processes are thread safe
    # and don't need any additional synchronization.
    class LockManager
      # Obtains a lock for the given process, blocking if necessary
      #
      # @param [Process] process
      # @return [undefined]
      def obtain_lock(process); end

      # Releases the lock for the given process
      #
      # @raise [ThreadError] If thread didn't previously hold the lock
      # @param [Process] process
      # @return [undefined]
      def release_lock(process); end
    end
  end
end
