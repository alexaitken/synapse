module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures a converter factory for serialization
      #
      # @see ConverterFactoryDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def converter_factory(identifier = nil, &block)
        with_definition_builder ConverterFactoryDefinitionBuilder, identifier, &block
      end

      # Creates and configures a serializer for partitioning, event storage, etc.
      #
      # @see SerializerDefinitionBuilder
      # @param [Symbol] identifier
      # @param [Proc] block
      # @return [undefined]
      def serializer(identifier = nil, &block)
        with_definition_builder SerializerDefinitionBuilder, identifier, &block
      end
    end # ContainerBuilder
  end # Configuration
end
