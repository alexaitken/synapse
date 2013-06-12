module Synapse
  module Domain
    # Raised when an event is published but the aggregate identifier is not set
    class AggregateIdentifierNotInitializedError < NonTransientError; end

    # Raised when the end of a domain event stream has been reached
    class EndOfStreamError < NonTransientError; end
  end
end
