module Synapse
  module Configuration
    # DSL for building service definitions
    class DefinitionBuilder
      # @return [Symbol]
      attr_reader :id

      # @yield [DefinitionBuilder]
      # @param [Container] container
      # @param [Symbol] id
      # @param [Proc] block
      # @return [undefined]
      def self.build(container, id = nil, &block)
        builder = self.new container, id
        builder.instance_exec(&block) if block
        builder.register_definition

        builder.id
      end

      # @param [Container] container
      # @param [Symbol] id
      # @return [undefined]
      def initialize(container, id = nil)
        @container = container
        @prototype = false
        @tags = Set.new

        populate_defaults

        @id = id.to_sym if id
      end

      # @param [Symbol] id
      # @return [undefined]
      def identified_by(id)
        @id = id.to_sym
      end

      # @return [undefined]
      def anonymous
        identified_by SecureRandom.hex 8
      end

      # @param [Symbol...] tags
      # @return [undefined]
      def tag(*tags)
        @tags.merge tags.flatten
      end

      # @return [undefined]
      def as_prototype
        @prototype = true
      end

      # @return [undefined]
      def as_singleton
        @prototype = false
      end

      # @param [Proc] factory
      # @return [undefined]
      def use_factory(&factory)
        @factory = proc do
          instance_exec(&factory)
        end
      end

      # @param [Object] instance
      # @return [undefined]
      def use_instance(instance)
        @instance = instance
      end

      # If the given value is a symbol, it will be resolved using the container. Otherwise, it
      # will be passed through
      #
      # @param [Object] value
      # @return [Object]
      def resolve(value, optional = false)
        if value.is_a? Symbol
          @container.resolve value, optional
        else
          value
        end
      end

      # Resolves all services that have the given tag
      #
      # @param [Symbol] tag
      # @return [Array]
      def resolve_tagged(tag)
        @container.resolve_tagged tag
      end

      # Convenience method for building composite services
      #
      # The given block will be executed in the context of the definition builder
      #
      # @param [Class] builder_type Defaults to DefinitionBuilder
      # @param [Proc] block
      # @return [Symbol] The identifier of the newly created service
      def build_composite(builder_type = DefinitionBuilder, &block)
        builder_type.build @container, &block
      end

      # @return [Definition]
      def build_definition
        Definition.new @tags, @prototype, @factory, @instance
      end

      # @return [undefined]
      def register_definition
        unless @id
          raise ConfigurationError, 'No identifier set for the definition'
        end

        @container.register @id, build_definition
      end

    protected

      # Sets the default values for the definition being built
      # @return [undefined]
      def populate_defaults; end

      # Resolves any services with the given tag and yields them
      #
      # @yield [Object]
      # @param [Symbol] tag
      # @return [undefined]
      def with_tagged(tag, &block)
        tagged = resolve_tagged tag
        tagged.each &block
      end
    end # DefinitionBuilder
  end # Configuration
end
