module Synapse
  module Repository
    # Represents a mechanism for loading and storing aggregates
    # @abstract
    class Repository
      # Loads an aggregate with the given aggregate identifier
      #
      # If an expected version is specified and the aggregate's actual version doesn't equal the
      # expected version, the implementation can choose to do one of the following:
      #
      # - Raise an exception immediately
      # - Raise an exception at any other time while the aggregate is registered with the current
      #   unit of work.
      #
      # @raise [AggregateNotFoundError]
      #   If the aggregate with the given identifier could not be found
      # @raise [ConflictingModificationError]
      #   If the expected version doesn't match the aggregate's actual version
      # @param [Object] aggregate_id
      # @param [Integer] expected_version If this is nil, no version validation is performed
      # @return [AggregateRoot]
      def load(aggregate_id, expected_version = nil); end

      # Adds a new, unmanaged aggregate to the repository
      #
      # This method will not force the repository to save the aggregate immediately. Instead, it is
      # registered with the current unit of work. To force storage of an aggregate, commit the
      # current unit of work.
      #
      # @raise [ArgumentError] If the version of the aggregate is not null
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def add(aggregate); end
    end
  end
end
