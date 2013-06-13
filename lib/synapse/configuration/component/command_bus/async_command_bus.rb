module Synapse
  module Configuration
    # Definition builder used to build an asynchronous command bus
    #
    # @see SimpleCommandBusDefinitionBuilder For additional options
    # @see Contender::Pool::ThreadPoolExecutor For pool options
    #
    # @example The minimum possible effort to build an asynchronous command bus
    #   async_command_bus
    #
    # @example Create an asynchronous command bus with a custom thread count
    #   async_command_bus do
    #     use_pool_options size: 2
    #   end
    class AsynchronousCommandBusDefinitionBuilder < SimpleCommandBusDefinitionBuilder
      include ThreadPoolDefinitionBuilder

    protected

      # @return [undefined]
      def populate_defaults
        super
        use_pool_options size: 4
      end

      # @param [UnitOfWorkFactory] unit_factory
      # @return [AsynchronousCommandBus]
      def create_command_bus(unit_factory)
        command_bus = Command::AsynchronousCommandBus.new unit_factory
        command_bus.thread_pool = create_thread_pool

        command_bus
      end
    end # AsynchronousCommandBusDefinitionBuilder
  end # Configuration
end
