module Synapse
  # Builder that is used to easily create and populate messages
  class MessageBuilder
    # @return [String]
    attr_accessor :id

    # @return [Hash]
    attr_accessor :metadata

    # @return [Object]
    attr_accessor :payload

    # Convenience method that yields a new builder, populates defaults and returns the newly
    # built message instance
    #
    # @yield [MessageBuilder]
    # @return [Message]
    def self.build
      builder = self.new

      yield builder if block_given?

      builder.populate_defaults
      builder.build
    end

    # @return [Message]
    def build
      Message.new @id, @metadata, @payload
    end

    # @return [undefined]
    def populate_defaults
      @id ||= IdentifierFactory.instance.generate
      @metadata ||= Hash.new
    end
  end
end
