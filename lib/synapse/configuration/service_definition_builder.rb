module Synapse
  module Configuration
    # DSL for building service definitions
    class ServiceDefinitionBuilder
      # @return [Symbol]
      attr_accessor :id

      # @return [Array]
      attr_accessor :tags

      # @param [Container] container
      # @param [ContainerBuilder] container_builder
      # @return [undefined]
      def initialize(container, container_builder)
        @container = container
        @container_builder = container_builder
        @tags = Array.new

        populate_defaults
      end

      # @return [ServiceDefinition]
      def build
        ServiceDefinition.new @id, @singleton, @factory, @instance
      end

      # @yield [Container]
      # @return [undefined]
      def with_factory(&factory)
        @factory = factory
        @singleton = true
      end

      # @param [Object] instance
      # @return [undefined]
      def with_instance(instance)
        @instance = instance
        @singleton = false
      end

      # @param [Symbol] tag
      # @return [undefined]
      def tag(tag)
        @tags.push tag
      end

    protected

      def resolve(value, optional = false)
        if value.is_a? Symbol
          @container.fetch value, optional
        elsif value
          value
        elsif not optional
          raise 'Value could not be resolved and is not optional'
        end
      end

      def populate_defaults; end
    end
  end
end
