module Synapse
  module Configuration
    # Definition builder used to create a simple command bus
    #
    # @example The minimum possible effort to build a command bus
    #   simple_command_bus
    #
    # @example Create a command bus with an alternate identifier and handler tag
    #   simple_command_bus :alt_command_bus do
    #     use_handler_tag :alt_command_handler
    #   end
    #
    # @todo Support for interceptors and filters
    class SimpleCommandBusDefinitionBuilder < DefinitionBuilder
      # Changes the tag to use to automatically subscribe command handlers
      #
      # Note that command handlers that are tagged must support self-subscription to the
      # command bus. An example of a handler capable of doing so is the wiring command handler.
      #
      # @param [Symbol] handler_tag
      # @return [undefined]
      def use_handler_tag(handler_tag)
        @handler_tag = handler_tag
      end

      # Changes the tag to use to automatically register command filters
      #
      # @param [Symbol] filter_tag
      # @return [undefined]
      def use_filter_tag(filter_tag)
        @filter_tag = filter_tag
      end

      # Changes the tag to use to automatically register command filters
      #
      # @param [Symbol] interceptor_tag
      # @return [undefined]
      def use_interceptor_tag(interceptor_tag)
        @interceptor_tag = interceptor_tag
      end

      # Changes the rollback policy to use for the command bus
      #
      # By default, the command bus will always rollback on an exception
      #
      # @param [Symbol] rollback_policy
      # @return [undefined]
      def use_rollback_policy(rollback_policy)
        @rollback_policy = rollback_policy
      end

      # Changes the unit of work factory to use with this command bus
      #
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
          command_bus.rollback_policy = resolve @rollback_policy, true

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
