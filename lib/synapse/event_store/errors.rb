module Synapse
  module EventStore
    # Raised when an error occurs when reading or appending events to an event store
    class EventStoreError < NonTransientError; end

    # Raised when a stream could not be found for a specific aggregate
    class StreamNotFoundError < EventStoreError; end
  end
end
