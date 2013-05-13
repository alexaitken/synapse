module Synapse
  module ProcessManager
    # Lock manager that does pessimistic locking for processes
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
    end
  end
end
