module Synapse
  class << self
    # @return [Configuration::Container]
    attr_accessor :container

    # @return [Configuration::ContainerBuilder]
    attr_accessor :container_builder

    # Initializes the service container and the container builder
    #
    # The given block is executed in the container of the container builder. Factory blocks are
    # always deferred until the service is needed to build another service or is manually
    # requested from the container.
    #
    # This method can be called multiple times without losing the state of the container.
    #
    # @example
    #   Synapse.build do
    #     definition :account_projection do
    #       tag :event_listener, :projection
    #       use_factory do
    #         Bank::Projections::AccountProjection.new
    #       end
    #     end
    #   end
    #
    # @see Configuration::ContainerBuilder#build_with
    # @param [Proc] block
    # @return [undefined]
    def build(&block)
      self.container ||= Configuration::Container.new
      self.container_builder ||= Configuration::ContainerBuilder.new self.container

      self.container_builder.build_with(&block)
    end

    # Initializes the service container and the container builder and applies simple defaults for
    # getting started with a single node setup
    #
    # @example
    #   Synapse.build_with_defaults do
    #     # Setup things like command handlers, event listeners and repositories
    #   end
    #
    # @see Configuration::ContainerBuilder#build_with
    # @param [Proc] block
    # @return [undefined]
    def build_with_defaults(&block)
      build do
        converter_factory
        serializer
        upcaster_chain

        unit_factory
        simple_command_bus
        gateway

        simple_event_bus
      end

      build &block
    end
  end
end
