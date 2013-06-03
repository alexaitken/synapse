require 'synapse/configuration/component/serialization/converter_factory'
require 'synapse/configuration/component/serialization/serializer'

module Synapse
  module Configuration
    class ContainerBuilder
      # Creates and configures a converter factory for serialization
      builder :converter_factory, ConverterFactoryDefinitionBuilder

      # Creates and configures a serializer for partitioning, event storage, etc.
      builder :serializer, SerializerDefinitionBuilder
    end # ContainerBuilder
  end # Configuration
end
