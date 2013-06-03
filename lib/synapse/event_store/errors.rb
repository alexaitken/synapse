module Synapse
  module EventStore
    # Raised when an error occurs when reading or appending events to an event store
    class EventStoreError < NonTransientError; end

    # Raised when a stream could not be found for a specific aggregate
    class StreamNotFoundError < EventStoreError
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @return [undefined]
      def initialize(type_identifier, aggregate_id)
        super 'Stream not found for [%s] [%s]' % [type_identifier, aggregate_id]
      end
    end # StreamNotFoundError
  end # EventStore
end
