module Synapse
  module Configuration
    # Definition builder used to build an asynchronous command bus
    #
    # @see SimpleCommandBusDefinitionBuilder For additional options
    #
    # @example The minimum possible effort to build an asynchronous command bus
    #   async_command_bus
    #
    # @example Create an asynchronous command bus with a custom thread count
    #   async_command_bus do
    #     use_threads 8, 12
    #   end
    class AsynchronousCommandBusDefinitionBuilder < SimpleCommandBusDefinitionBuilder
      # @param [Integer] min_threads
      # @param [Integer] max_threads
      # @return [undefined]
      def use_threads(min_threads, max_threads = nil)
        @min_threads = min_threads
        @max_threads = max_threads
      end

    protected

      # @return [undefined]
      def populate_defaults
        super
        use_threads 4
      end

      # @param [UnitOfWorkFactory] unit_factory
      # @return [AsynchronousCommandBus]
      def create_command_bus(unit_factory)
        command_bus = Command::AsynchronousCommandBus.new unit_factory
        command_bus.tap do
          command_bus.thread_pool = Thread.pool @min_threads, @max_threads
        end
      end
    end # AsynchronousCommandBusDefinitionBuilder
  end # Configuration
end
