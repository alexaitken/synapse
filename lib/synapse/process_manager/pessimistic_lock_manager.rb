module Synapse
  module ProcessManager
    # Lock manager that does pessimistic locking for processes
    class PessimisticLockManager
      def initialize
        @lock = IdentifierLock.new
      end

      # @param [Process] process
      # @return [undefined]
      def obtain_lock(process)
        @lock.obtain_lock process.id
      end

      # @raise [ThreadError] If thread didn't previously hold the lock
      # @param [Process] process
      # @return [undefined]
      def release_lock(process)
        @lock.release_lock process.id
      end
    end
  end
end
