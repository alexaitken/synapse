module Synapse
  module ProcessManager
    # Represents a mechanism for synchronizing access to processes
    #
    # This base implementation does no locking; it can be used if processes are thread safe
    # and don't need any additional synchronization.
    class LockManager
      # Obtains a lock for a process with the given identifier, blocking if necessary
      #
      # @param [String] process_id
      # @return [undefined]
      def obtain_lock(process_id); end

      # Releases the lock for a process with the given identifier
      #
      # @raise [ThreadError] If thread didn't previously hold the lock
      # @param [String] process_id
      # @return [undefined]
      def release_lock(process_id); end
    end
  end
end
