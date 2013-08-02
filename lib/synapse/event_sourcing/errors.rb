module Synapse
  module EventSourcing
    # Raised when an aggregate has been found but it was marked for deletion
    class AggregateDeletedError < Repository::AggregateNotFoundError
      # @param [String] type_identifier
      # @param [Object] aggregate_id
      # @return [undefined]
      def initialize(type_identifier, aggregate_id)
        super "Aggregate {#{type_identifier}} {#{aggregate_id}} has been marked for deletion"
      end
    end # AggregateDeletedError
  end # EventSourcing
end
