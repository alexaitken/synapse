module Synapse
  module Saga
    # Saga repository that stores all sagas in memory
    #
    # While the storage of sagas are thread-safe, the sagas themselves may not be. Use a
    # lock manager if the sagas are not thread-safe.
    class InMemorySagaRepository < SagaRepository
      # @return [undefined]
      def initialize
        @managed_sagas = ThreadSafe::Cache.new
      end

      # @param [Class] type
      # @param [Correlation] correlation
      # @return [Set]
      def find(type, correlation)
        matching = Set.new

        @managed_sagas.each_value do |saga|
          if saga.correlations.include?(correlation)
            matching.add(saga.id)
          end
        end

        matching
      end

      # @param [String] id
      # @return [Saga] Returns nil if saga could not be found
      def load(id)
        @managed_sagas.get(id)
      end

      # @param [Saga] saga
      # @return [undefined]
      def commit(saga)
        if saga.active?
          @managed_sagas.put(saga.id, saga)
        else
          @managed_sagas.delete(saga.id)
        end

        saga.correlations.commit
      end

      # @param [Saga] saga
      # @return [undefined]
      def add(saga)
        commit(saga)
      end

      # Returns the number of sagas managed by this repository
      # @return [Integer]
      def size
        @managed_sagas.size
      end
    end # InMemorySagaRepository
  end # Saga
end
