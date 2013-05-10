module Synapse
  module Serialization
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Converter
      autoload :ConverterFactory,  'synapse/serialization/converter/factory'
      autoload :IdentityConverter, 'synapse/serialization/converter/identity'

      autoload_at 'synapse/serialization/errors' do
        autoload :ConversionError
        autoload :SerializationError
        autoload :UnknownSerializedTypeError
      end

      autoload_at 'synapse/serialization/lazy_object' do
        autoload :DeserializedObject
        autoload :LazyObject
      end

      autoload_at 'synapse/serialization/revision_resolver' do
        autoload :RevisionResolver
        autoload :FixedRevisionResolver
      end

      autoload :SerializedDomainEventData, 'synapse/serialization/message/data'
      autoload :MessageSerializer, 'synapse/serialization/message/serializer'
      autoload :SerializedMetadata, 'synapse/serialization/message/metadata'
      autoload :SerializationAware, 'synapse/serialization/message/serialization_aware'
      autoload :SerializedObjectCache, 'synapse/serialization/message/serialized_object_cache'

      autoload_at 'synapse/serialization/message/serialization_aware_message' do
        autoload :SerializationAwareEventMessage
        autoload :SerializationAwareDomainEventMessage
      end

      autoload_at 'synapse/serialization/message/serialized_message' do
        autoload :SerializedMessage
        autoload :SerializedEventMessage
        autoload :SerializedDomainEventMessage
      end

      autoload_at 'synapse/serialization/message/serialized_message_builder' do
        autoload :SerializedMessageBuilder
        autoload :SerializedEventMessageBuilder
        autoload :SerializedDomainEventMessageBuilder
      end

      autoload :Serializer
      autoload :SerializedObject
      autoload :SerializedType
    end

    autoload_at 'synapse/serialization/converter/json' do
      autoload :JsonToObjectConverter
      autoload :ObjectToJsonConverter
    end

    autoload_at 'synapse/serialization/converter/ox' do
      autoload :XmlToOxDocumentConverter
      autoload :OxDocumentToXmlConverter
    end

    autoload :OjSerializer, 'synapse/serialization/serializer/oj'
    autoload :OxSerializer, 'synapse/serialization/serializer/ox'
    autoload :MarshalSerializer, 'synapse/serialization/serializer/marshal'
  end
end
