module Synapse
  module Serialization
    extend ActiveSupport::Autoload

    # Optional converters
    autoload_at 'synapse/serialization/converter/json' do
      autoload :JsonToObjectConverter
      autoload :ObjectToJsonConverter
    end

    autoload_at 'synapse/serialization/converter/ox' do
      autoload :XmlToOxDocumentConverter
      autoload :OxDocumentToXmlConverter
    end

    autoload :OrderedHashToHashConverter, 'synapse/serialization/converter/bson'

    # Optional serializers
    autoload :AttributeSerializer, 'synapse/serialization/serializer/attribute'
    autoload :OjSerializer, 'synapse/serialization/serializer/oj'
    autoload :OxSerializer, 'synapse/serialization/serializer/ox'
    autoload :MarshalSerializer, 'synapse/serialization/serializer/marshal'
  end
end

require 'synapse/serialization/converter_factory'
require 'synapse/serialization/converter'
require 'synapse/serialization/converter/chain'
require 'synapse/serialization/converter/identity'

require 'synapse/serialization/errors'

require 'synapse/serialization/lazy_object'
require 'synapse/serialization/revision_resolver'
require 'synapse/serialization/serialized_object'
require 'synapse/serialization/serialized_type'
require 'synapse/serialization/serializer'

require 'synapse/serialization/message/data'
require 'synapse/serialization/message/metadata'
require 'synapse/serialization/message/serialization_aware'
require 'synapse/serialization/message/serialization_aware_message'
require 'synapse/serialization/message/serialized_message_builder'
require 'synapse/serialization/message/serialized_message'
require 'synapse/serialization/message/serialized_object_cache'
require 'synapse/serialization/message/serializer'
