module Synapse
  module Command
    # Represents a mechanism for determining whether or not to rollback the unit of work for a
    # command dispatch in case an exception occurs during the dispatch
    class RollbackPolicy
      include AbstractType

      # Returns true if the unit of work should be rolled back
      #
      # @param [Exception] exception
      # @return [Boolean]
      abstract_method :should_rollback?
    end # RollbackPolicy

    # Implementation of a rollback policy that performs a rollback on any exception
    class RollbackOnAnyExceptionPolicy < RollbackPolicy
      # @param [Exception] exception
      # @return [Boolean]
      def should_rollback?(exception)
        true
      end
    end # RollbackOnAnyExceptionPolicy
  end # Command
end
