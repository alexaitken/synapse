module Synapse
  # @todo Deadlock detection
  # @todo Disposing of unused locks
  class IdentifierLock
    # @return [undefined]
    def initialize
      @identifiers = Hash.new
      @lock = Mutex.new
    end

    # Returns true if the calling thread holds the lock for the given identifier
    #
    # @param [Object] identifier
    # @return [Boolean]
    def owned?(identifier)
      lock_available?(identifier) and lock_for(identifier).owned?
    end

    # Obtains a lock for the given identifier, blocking until the lock is obtained
    #
    # @param [Object] identifier
    # @return [undefined]
    def obtain_lock(identifier)
      lock_for(identifier).lock
    end

    # Releases a lock for the given identifier
    #
    # @raise [ArgumentError] If no lock was ever obtained for the identifier
    # @param [Object] identifier
    # @return [undefined]
    def release_lock(identifier)
      unless lock_available? identifier
        raise ArgumentError, 'No lock for this identifier was ever obtained'
      end

      lock_for(identifier).unlock
    end

  private

    def lock_for(identifier)
      @lock.synchronize do
        if lock_available? identifier
          @identifiers.fetch identifier
        else
          @identifiers.store identifier, PublicLock.new
        end
      end
    end

    def lock_available?(identifier)
      @identifiers.has_key? identifier
    end
  end
end
