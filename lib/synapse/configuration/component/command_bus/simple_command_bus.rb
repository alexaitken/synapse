module Synapse
  module Configuration
    # Definition builder used to create a simple command bus
    #
    # @example The minimum possible effort to build a command bus
    #   simple_command_bus
    #
    # @example Create a command bus with an alternate identifier and tags
    #   simple_command_bus :alt_command_bus do
    #     use_handler_tag :alt_command_handler
    #     use_filter_tag :alt_command_filter
    #     use_interceptor_tag :alt_dispatch_interceptor
    #   end
    class SimpleCommandBusDefinitionBuilder < DefinitionBuilder
      # Changes the tag to use to automatically subscribe command handlers
      #
      # Note that command handlers that are tagged must support self-subscription to the
      # command bus. An example of a handler capable of doing so is the wiring command handler.
      #
      # @see Command::MappingCommandHandler
      # @param [Symbol] handler_tag
      # @return [undefined]
      def use_handler_tag(handler_tag)
        @handler_tag = handler_tag
      end

      # Changes the tag to use to automatically register command filters
      #
      # @see Command::CommandFilter
      # @param [Symbol] filter_tag
      # @return [undefined]
      def use_filter_tag(filter_tag)
        @filter_tag = filter_tag
      end

      # Changes the tag to use to automatically register command filters
      #
      # @see Command::DispatchInterceptor
      # @param [Symbol] interceptor_tag
      # @return [undefined]
      def use_interceptor_tag(interceptor_tag)
        @interceptor_tag = interceptor_tag
      end

      # Changes the rollback policy to use for the command bus
      #
      # By default, the command bus will always rollback on an exception
      #
      # @see Command::RollbackPolicy
      # @param [Symbol] rollback_policy
      # @return [undefined]
      def use_rollback_policy(rollback_policy)
        @rollback_policy = rollback_policy
      end

      # Changes the unit of work factory to use with this command bus
      #
      # @see UnitOfWork::UnitOfWorkFactory
      # @param [Symbol] unit_factory
      # @return [undefined]
      def use_unit_factory(unit_factory)
        @unit_factory = unit_factory
      end

    protected

      # @return [undefined]
      def populate_defaults
        identified_by :command_bus

        use_handler_tag :command_handler
        use_filter_tag :command_filter
        use_interceptor_tag :dispatch_interceptor

        use_unit_factory :unit_factory

        use_factory do
          unit_factory = resolve @unit_factory

          command_bus = create_command_bus unit_factory

          if @rollback_policy
            command_bus.rollback_policy = resolve @rollback_policy
          end

          with_tagged @handler_tag do |handler|
            handler.subscribe command_bus
          end

          with_tagged @filter_tag do |filter|
            command_bus.filters.push filter
          end

          with_tagged @interceptor_tag do |interceptor|
            command_bus.interceptors.push interceptor
          end

          command_bus
        end
      end

      # Creates an instance of SimpleCommandBus with the given unit of work factory
      #
      # This can be overriden to serve up special subclasses of SimpleCommandBus
      #
      # @param [UnitOfWorkFactory] unit_factory
      # @return [SimpleCommandBus]
      def create_command_bus(unit_factory)
        Command::SimpleCommandBus.new unit_factory
      end
    end # SimpleCommandBusDefinitionBuilder
  end # Configuration
end
