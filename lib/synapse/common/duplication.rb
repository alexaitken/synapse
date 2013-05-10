module Synapse
  # Records messages as they are sent to a bus so that duplicates can be tracked and prevented.
  # Inspired by the de-duplication manager from Lokad.CQRS
  #
  # This implementation is thread-safe
  class DuplicationRecorder
    def initialize
      @recorded = Hash.new
      @lock = Mutex.new
    end

    # Records the given message so that duplicates can be ignored
    #
    # @raise [DuplicationError] If a duplicate message has been detected
    # @param [Message] message
    # @return [undefined]
    def record(message)
      @lock.synchronize do
        if @recorded.has_key? message.id
          raise DuplicationError
        end

        @recorded.store message.id, Time.now
      end
    end

    # Returns true if the given message has been recorded
    #
    # @param [Message] message
    # @return [Boolean]
    def recorded?(message)
      @recorded.has_key? message.id
    end

    # Forgets the given message
    #
    # @param [Message] message
    # @return [undefined]
    def forget(message)
      @lock.synchronize do
        @recorded.delete message.id
      end
    end

    # Cleans up messages that are older than the given timestamp
    #
    # @param [Time] threshold
    # @return [undefined]
    def forget_older_than(threshold)
      @lock.synchronize do
        @recorded.delete_if do |message_id, timestamp|
          timestamp <= threshold
        end
      end
    end
  end

  # Raised when a duplicate message has been detected by the duplication recorder
  class DuplicationError < NonTransientError; end
end
