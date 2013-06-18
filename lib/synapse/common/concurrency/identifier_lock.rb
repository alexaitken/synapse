module Synapse
  # Generic implementation of a lock that can be used to lock an identifier for use
  # @todo Deadlock detection
  class IdentifierLock
    # @return [undefined]
    def initialize
      @identifiers = Hash.new
      @mutex = Mutex.new
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
    # @raise [ThreadError] If no lock was ever obtained for the identifier
    # @param [Object] identifier
    # @return [undefined]
    def release_lock(identifier)
      unless lock_available? identifier
        raise ThreadError, 'No lock for this identifier was ever obtained'
      end

      lock_for(identifier).unlock
    end

  private

    def lock_for(identifier)
      @mutex.synchronize do
        if @identifiers.has_key? identifier
          @identifiers[identifier]
        else
          @identifiers[identifier] = PublicLock.new
        end
      end
    end

    def lock_available?(identifier)
      @identifiers.has_key? identifier
    end
  end # IdentifierLock
end
