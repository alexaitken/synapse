require 'synapse/mapping/errors'
require 'synapse/mapping/message_handler'
require 'synapse/mapping/message_handler_score'
require 'synapse/mapping/message_mapper'
require 'synapse/mapping/parameter_resolver'
require 'synapse/mapping/parameter_resolver_factory'

module Synapse
  module Mapping
    extend self

    # Built-in parameter resolver types
    DEFAULT_RESOLVER_TYPES = [
      PayloadParameterResolver,
      MetadataParameterResolver,
      MessageParameterResolver,
      TimestampParameterResolver,
      AggregateIdParameterResolver,
      SequenceNumberParameterResolver,
      CurrentUnitParameterResolver
    ]

    # @return [ParameterResolverFactory]
    attr_accessor :resolver_factory

    # @param [Boolean] duplicates_allowed
    # @return [MessageMapper]
    def create_mapper(duplicates_allowed = true)
      MessageMapper.new duplicates_allowed
    end

    # @return [undefined]
    def setup_resolver_factory
      @resolver_factory = ParameterResolverFactory.new

      DEFAULT_RESOLVER_TYPES.each do |type|
        @resolver_factory.register type.new
      end
    end

    setup_resolver_factory
  end
end
