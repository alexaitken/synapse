module Synapse
  module Configuration
    # Provides a DSL for easily configuring different components of the infrastructure needed to
    # leverage Synapse in an application
    class ContainerBuilder
      # @return [Array]
      class_attribute :defaults
      self.defaults = Array.new

      # Registers a default service that will be built when the container builder is created
      #
      # @yield [ServiceDefinitionBuilder]
      # @return [undefined]
      def self.default(&block)
        self.defaults.push block
      end

      # @param [Container] container
      # @return [undefined]
      def initialize(container)
        @container = container

        defaults.each do |definition_factory|
          service(&definition_factory)
        end
      end

      # @yield [ServiceDefinitionBuilder]
      # @return [undefined]
      def service(&block)
        with_builder ServiceDefinitionBuilder, &block
      end

    protected

      # Creates a builder with the given class, yields it to the block and then registers it
      # to the definition container
      #
      # @yield [ServiceDefinitionBuilder]
      # @param [Class] builder_class
      # @return [undefined]
      def with_builder(builder_class, &block)
        builder = builder_class.new @container, self

        if block
          block.call builder
        end

        definition = builder.build

        @container.register definition
        builder.tags.each do |tag|
          @container.tag_service tag, definition.id
        end
      end
    end # ContainerBuilder
  end # Configuration
end
