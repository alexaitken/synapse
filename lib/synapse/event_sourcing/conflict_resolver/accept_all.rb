module Synapse
  module EventSourcing
    # Conflict resolver that accepts any unseen changes to an aggregate
    class AcceptAllConflictResolver < ConflictResolver
      # @raise [ConflictingModificationError] If any conflicts were detected
      # @param [Array] applied_changes List of changes applied to the aggregate
      # @param [Array] committed_changes List of events that were unexpected by the command handler
      # @return [undefined]
      def resolve_conflicts(applied_changes, committed_changes)
        # This method is intentionally empty
      end
    end # AcceptAllConflictResolver
  end # EventSourcing
end
