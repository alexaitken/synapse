module Synapse
  module Concurrent
    class LockUsageError < NonTransientError; end
    class LockAcquisitionError < TransientError; end
    class DeadlockError < LockAcquisitionError; end
  end
end
