module Synapse
  module Saga
    # Saga repository that stores all sagas in memory
    #
    # While the storage of sagas are thread-safe, the sagas themselves may not be. Use a
    # lock manager if the sagas are not thread-safe.
    #
    # @todo I'm not so sure of the thread-safety of this class
    class InMemorySagaRepository < SagaRepository
      def initialize
        @managed_sagas = Hash.new
        @mutex = Mutex.new
      end

      # @param [Class] type
      # @param [Correlation] correlation
      # @return [Set]
      def find(type, correlation)
        matching = Array.new

        @managed_sagas.each_value do |saga|
          if saga.correlations.include? correlation
            matching.push saga.id
          end
        end

        matching
      end

      # @param [String] id
      # @return [Saga] Returns nil if saga could not be found
      def load(id)
        if @managed_sagas.has_key? id
          @managed_sagas.fetch id
        end
      end

      # @param [Saga] saga
      # @return [undefined]
      def commit(saga)
        @mutex.synchronize do
          if saga.active?
            @managed_sagas.store saga.id, saga
          else
            @managed_sagas.delete saga.id
          end
        end

        saga.correlations.commit
      end

      # @param [Saga] saga
      # @return [undefined]
      def add(saga)
        if saga.active?
          commit saga
        end
      end

      # @return [Integer] The number of sagas managed by this repository
      def count
        @managed_sagas.count
      end
    end # InMemorySagaRepository
  end # Saga
end
