module Synapse
  module ProcessManager
    # Process repository that stores all processes in memory
    #
    # This implementation is not thread-safe -- use a lock manager for thread safety
    class InMemoryProcessRepository < ProcessRepository
      def initialize
        @managed_processes = Hash.new
        @lock = Mutex.new
      end

      # @param [Class] type
      # @param [Correlation] correlation
      # @return [Set]
      def find(type, correlation)
        matching = Array.new

        @managed_processes.each_value do |process|
          if process.correlations.include? correlation
            matching.push process.id
          end
        end

        matching
      end

      # @param [String] id
      # @return [Process] Returns nil if process could not be found
      def load(id)
        if @managed_processes.has_key? id
          @managed_processes.fetch id
        end
      end

      # @param [Process] process
      # @return [undefined]
      def commit(process)
        @lock.synchronize do
          if process.active?
            @managed_processes.store process.id, process
          else
            @managed_processes.delete process.id
          end
        end

        process.correlations.commit
      end

      # @param [Process] process
      # @return [undefined]
      def add(process)
        if process.active?
          commit process
        end
      end

      # @return [Integer] The number of processes managed by this repository
      def count
        @managed_processes.count
      end
    end # InMemoryProcessRepository
  end # ProcessManager
end
