module Synapse
  module Configuration
    # Provides a DSL for end-users to easily configure the Synapse service container
    # @see Synapse#build
    class ContainerBuilder
      # Registered initializers that will be executed upon instantiation
      # @return [Array]
      class_attribute :initializers

      # Registers a block that will be executed upon instantiation of a container builder
      #
      # This is useful for defining common services that are likely to be depended upon by
      # other services being built
      #
      # @param [Proc] initializer
      # @return [undefined]
      def self.initializer(&initializer)
        self.initializers ||= Array.new
        self.initializers.push initializer
      end

      # @return [Container]
      attr_reader :container

      # @param [Container] container
      # @return [undefined]
      def initialize(container)
        @container = container

        if initializers
          initializers.each do |initializer|
            build_with(&initializer)
          end
        end
      end

      # Executes the given block in the context of the container builder
      #
      # @param [Proc] block
      # @return [undefined]
      def build_with(&block)
        instance_exec(&block)
      end

      # Executes the given build in the context of a new definition builder
      #
      # @example
      #   definition :account_projection do
      #     tag :event_listener, :projection
      #     use_factory do
      #       AccountProjection.new
      #     end
      #   end
      #
      # @see #factory If the definition being created is simple
      # @see DefinitionBuilder
      # @param [Symbol] id
      # @param [Proc] block
      # @return [undefined]
      def definition(id = nil, &block)
        with_definition_builder DefinitionBuilder, id, &block
      end

      # Simple usage of the definition builder
      #
      # The given block is used as a deferred factory and will be executed in the context of the
      # definition builder. If a tag option is provided, the definition will be tagged with the
      # given symbols.
      #
      # The definition that is created will be a singleton.
      #
      # @example
      #   factory :account_projection, :tag => [:event_listener, :projection] do
      #     AccountProjection.new
      #   end
      #
      # @see DefinitionBuilder#use_factory
      # @param [Symbol] id
      # @param [Object...] args
      # @param [Proc] block
      # @return [undefined]
      def factory(id, *args, &block)
        options = args.extract_options!

        with_definition_builder DefinitionBuilder, id do
          use_factory(&block)
          if options.has_key? :tag
            tag(*options.fetch(:tag))
          end
        end
      end

    protected

      # Creates a definition builder of the given type, uses the identifier (if any is given),
      # executes the block in the context of the definition builder, then finally builds and
      # registers the definition with this builder's associate container.
      #
      # @param [Class] builder_type
      # @param [Symbol] id
      # @param [Proc] block
      # @return [undefined]
      def with_definition_builder(builder_type, id, &block)
        builder_type.build @container, id, &block
      end
    end
  end
end