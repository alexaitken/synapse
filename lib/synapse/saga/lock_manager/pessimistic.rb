module Synapse
  module Saga
    # Lock manager that blocks until a lock can be obtained for a saga
    class PessimisticLockManager < LockManager
      # @return [undefined]
      def initialize
        @manager = Concurrent::IdentifierLock.new
      end

      # @param [String] saga_id
      # @return [undefined]
      def obtain_lock(saga_id)
        @manager.obtain_lock saga_id
      end

      # @raise [ThreadError] If thread didn't previously hold the lock
      # @param [String] saga_id
      # @return [undefined]
      def release_lock(saga_id)
        @manager.release_lock saga_id
      end
    end # PessimisticLockManager
  end # Saga
end
