module Synapse
  module Repository
    # Raised when an aggregate could not be found by a repository
    class AggregateNotFoundError < NonTransientError; end

    # Raised when concurrent access to a repository was detected; the cause is most likely
    # that two threads were modifying the same aggregate.
    class ConcurrencyError < TransientError; end

    # Raised when conflicting concurrent modifications are detected
    class ConflictingModificationError < NonTransientError; end

    # Raised when the version number of the aggregate being loaded didn't match the expected
    # version number given. This typically means that the aggregate has been modified by another
    # thread between the moment the data was queried and the command modifying the aggregate
    # was handled.
    class ConflictingAggregateVersionError < ConflictingModificationError
      # @param [AggregateRoot] aggregate
      # @param [Integer] expected_version
      # @return [undefined]
      def initialize(aggregate, expected_version)
        super 'Aggregate [%s] has version %s, expected %s' % [aggregate.id, aggregate.version, expected_version]
      end
    end
  end
end
