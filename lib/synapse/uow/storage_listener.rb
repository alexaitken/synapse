module Synapse
  module UnitOfWork
    # Represents a mechanism for a unit of work to commit an aggregate to an underlying store
    # @abstract
    class StorageListener
      # Commits the given aggregate to the underlying storage mechanism
      #
      # @abstract
      # @param [AggregateRoot] aggregate
      # @return [undefined]
      def store(aggregate); end
    end
  end
end