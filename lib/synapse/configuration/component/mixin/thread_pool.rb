module Synapse
  module Configuration
    # Mixin for a definition builder that creates a service that is backed by a thread pool
    module ThreadPoolDefinitionBuilder
      extend ActiveSupport::Concern

      # Sets the upper and lower limits of the size of the thread pool
      #
      # @param [Integer] min_threads
      # @param [Integer] max_threads
      # @return [undefined]
      def use_threads(min_threads, max_threads = nil)
        @min_threads = min_threads
        @max_threads = max_threads
      end

    protected

      # Creates a thread pool with the configured options
      # @return [Thread::Pool]
      def create_thread_pool
        Thread.pool @min_threads, @max_threads
      end
    end # ThreadPoolDefinitionBuilder
  end # Configuration
end
