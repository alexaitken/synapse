require 'synapse/router/errors'
require 'synapse/router/message_handler'
require 'synapse/router/message_handler_score'
require 'synapse/router/message_router'
require 'synapse/router/parameter_resolver'
require 'synapse/router/parameter_resolver_factory'

module Synapse
  module Router
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
    # @return [MessageRouter]
    def create_router(duplicates_allowed = true)
      MessageRouter.new duplicates_allowed
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
