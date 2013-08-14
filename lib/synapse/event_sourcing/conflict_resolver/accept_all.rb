module Synapse
  module EventSourcing
    # Implementation of a conflict resolver that accepts all changes to an aggregate
    class AcceptAllConflictResolver < ConflictResolver
      # @return [undefined]
      def resolve_conflicts(*)
        # This method is intentionally empty
      end
    end # AcceptAllConflictResolver
  end # EventSourcing
end
