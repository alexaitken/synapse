module Synapse
  module EventSourcing
    # Raised when an aggregate has been found but it was marked for deletion
    class AggregateDeletedError < Persistence::AggregateNotFoundError; end
  end # EventSourcing
end
