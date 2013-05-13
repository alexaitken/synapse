module Synapse
  module Configuration
    # Extension to the container builder that adds a service definition builder for
    # SimpleCommandBus
    class ContainerBuilder
      # @yield [SimpleCommandBusDefinitionBuilder]
      # @return [undefined]
      def simple_command_bus(&block)
        with_builder SimpleCommandBusDefinitionBuilder, &block
      end
    end

    # Service definition builder that makes it easier to use a simple command bus, along with
    # filters and interceptors that are commonly used with the bus
    class SimpleCommandBusDefinitionBuilder < ServiceDefinitionBuilder
      # @return [Symbol] Identifier of the service to use for the unit of work factory
      attr_accessor :unit_factory
      # @return [Symbol] Tag to use to lookup interceptors to use for this command bus
      attr_accessor :interceptor_tag
      # @return [Symbol] Tag to use to lookup filters to use for this command bus
      attr_accessor :filter_tag
      # @return [Symbol] Tag to use to lookup handlers to use for this command bus
      attr_accessor :handler_tag
      # @return [Symbol] Rollback policy to use
      attr_accessor :rollback_policy

      # @see [#with_deduplication]
      # @see [#with_serialization_optimization]
      # @see [#with_validation]
      # @return [undefined]
      def with_all
        with_deduplication
        with_serialization_optimization
        with_validation
      end

      # Adds the necessary filter and interceptor needed to prevent duplicate commands from
      # reaching command handlers
      #
      # @see [Command::DuplicationFilter]
      # @see [Command::DuplicationCleanupInterceptor]
      # @return [undefined]
      def with_deduplication
        recorder = DuplicationRecorder.new

        @container_builder.service do |service|
          service.id = :command_duplication_filter
          service.with_factory do
            Command::DuplicationFilter.new recorder
          end
          service.tag @filter_tag
        end

        @container_builder.service do |service|
          service.id = :command_duplication_cleanup_interceptor
          service.with_factory do
            Command::DuplicationCleanupInterceptor.new recorder
          end
          service.tag @interceptor_tag
        end
      end

      # Adds an interceptor that adds serialization optimization to events resulting from a
      # command dispatch
      #
      # @see [Command::SerializationOptimizingInterceptor]
      # @return [undefined]
      def with_serialization_optimization
        @container_builder.service do |service|
          service.id = :command_serialization_optimization_interceptor
          service.with_factory do
            Command::SerializationOptimizingInterceptor.new
          end
          service.tag @interceptor_tag
        end
      end

      # @see [Command::ActiveModelValidationFilter]
      # @return [undefined]
      def with_validation
        @container_builder.service do |service|
          service.id = :command_active_model_validation_filter
          service.with_factory do
            Command::ActiveModelValidationFilter.new
          end
          service.tag @filter_tag
        end
      end

    protected

      # @return [undefined]
      def populate_defaults
        @id = :command_bus

        @unit_factory = :unit_factory
        @interceptor_tag = :command_dispatch_interceptor
        @filter_tag = :command_filter
        @handler_tag = :command_handler

        with_factory do |container|
          unit_factory = resolve @unit_factory
          command_bus = Command::SimpleCommandBus.new unit_factory
          command_bus.tap do
            # Register any interceptors tagged for this command bus
            interceptors = container.fetch_tagged @interceptor_tag
            interceptors.each do |interceptor|
              command_bus.interceptors.push interceptor
            end

            # Register any filters tagged for this command bus
            filters = container.fetch_tagged @filter_tag
            filters.each do |filter|
              command_bus.filters.push filter
            end

            # Subscribes any handlers tagged for this command bus
            handlers = container.fetch_tagged @handler_tag
            handlers.each do |handler|
              handler.subscribe command_bus
            end

            # Set the rollback policy, if any was provided
            rollback_policy = resolve @rollback_policy, true
            if rollback_policy
              command_bus.rollback_policy = rollback_policy
            end
          end
        end
      end
    end # SimpleCommandBusDefinitionBuilder
  end # Configuration
end
