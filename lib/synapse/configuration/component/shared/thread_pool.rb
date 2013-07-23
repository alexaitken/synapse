module Synapse
  module Configuration
    # Mixin for a definition builder that creates a service that is backed by a thread pool
    # @see Contender::Pool::ThreadPoolExecutor For pool options
    module ThreadPoolDefinitionBuilder
      extend ActiveSupport::Concern

      # Sets the options for the thread pool
      #
      # @param [Hash] pool_options
      # @return [undefined]
      def use_pool_options(pool_options)
        @pool_options = pool_options
      end

      protected

      # Creates a thread pool with the configured options
      # @return [Contender::Pool::ThreadPoolExecutor]
      def create_thread_pool
        pool = Contender::Pool::ThreadPoolExecutor.new @pool_options
        pool.start

        pool
      end
    end # ThreadPoolDefinitionBuilder
  end # Configuration
end
