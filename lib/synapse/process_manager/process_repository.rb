module Synapse
  module ProcessManager
    # Represents a mechanism for storing and loading process instances
    # @abstract
    class ProcessRepository
      # Returns a set of process identifiers for processes of the given type that have been
      # correlated with the given key value pair
      #
      # Processes that have been changed must be committed for changes to take effect
      #
      # @abstract
      # @param [Class] type
      # @param [Correlation] correlation
      # @return [Set]
      def find(type, correlation)
        raise NotImplementedError
      end

      # Loads a known process by its unique identifier
      #
      # Processes that have been changed must be committed for changes to take effect
      #
      # Due to the concurrent nature of processes, it is not unlikely for a process to have
      # ceased to exist after it has been found based on correlations. Therefore, a repository
      # should gracefully handle a missing process.
      #
      # @abstract
      # @param [String] id
      # @return [Process] Returns nil if process could not be found
      def load(id)
        raise NotImplementedError
      end

      # Commits the changes made to the process instance
      #
      # If the committed process is marked as inactive, it should delete the process from the
      # underlying storage and remove all correlations for that process.
      #
      # @abstract
      # @param [Process] process
      # @return [undefined]
      def commit(process)
        raise NotImplementedError
      end

      # Registers a newly created process with the repository
      #
      # Once a process has been registered, it can be found using its correlations or by its
      # unique identifier.
      #
      # Note that if the added process is marked as inactive, it will not be stored.
      #
      # @abstract
      # @param [Process] process
      # @return [undefined]
      def add(process)
        raise NotImplementedError
      end
    end # ProcessRepository
  end # ProcessManager
end
