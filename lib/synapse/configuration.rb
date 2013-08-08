module Synapse
  # @api public
  module Configuration
    extend self

    # @return [IdentifierFactory]
    attr_accessor :identifier_factory

    # @return [Logger]
    attr_accessor :logger

    def configure
      yield self if block_given?
      populate_defaults
    end

    # @return [undefined]
    def populate_defaults
      @identifier_factory ||= UUIDIdentifierFactory.new
      @logger ||= Logger.new $stdout
    end
  end
end
