require 'synapse/serialization/converter'
require 'synapse/serialization/converter/chain'
require 'synapse/serialization/converter/identity'
require 'synapse/serialization/converter/json'

require 'synapse/serialization/converter_factory'
require 'synapse/serialization/errors'
require 'synapse/serialization/lazy_object'

require 'synapse/serialization/revision_resolver'
require 'synapse/serialization/revision_resolver/fixed'

require 'synapse/serialization/serializer'
require 'synapse/serialization/serializer/marshal'

require 'synapse/serialization/serialized_object'
require 'synapse/serialization/serialized_type'

require 'synapse/serialization/message/data'
require 'synapse/serialization/message/serialization_aware'
require 'synapse/serialization/message/serialization_aware_message'
require 'synapse/serialization/message/serialized_message'
require 'synapse/serialization/message/serialized_message_builder'
require 'synapse/serialization/message/serialized_metadata'
require 'synapse/serialization/message/serialized_object_cache'
require 'synapse/serialization/message/serializer'

module Synapse
  module Serialization
    extend self

    # @return [ConverterFactory]
    attr_accessor :converter_factory

    # @return [undefined]
    def setup_converter_factory
      @converter_factory = ConverterFactory.new
    end

    setup_converter_factory
  end
end
