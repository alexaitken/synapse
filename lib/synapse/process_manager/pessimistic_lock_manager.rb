module Synapse
  module ProcessManager
    # Lock manager that blocks until a lock can be obtained for a process
    class PessimisticLockManager
      def initialize
        @lock = IdentifierLock.new
      end

      # @param [String] process_id
      # @return [undefined]
      def obtain_lock(process_id)
        @lock.obtain_lock process_id
      end

      # @raise [ThreadError] If thread didn't previously hold the lock
      # @param [String] process_id
      # @return [undefined]
      def release_lock(process_id)
        @lock.release_lock process_id
      end
    end # PessimisticLockManager
  end # ProcessManager
end
