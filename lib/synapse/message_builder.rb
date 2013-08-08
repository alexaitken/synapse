module Synapse
  # Builder that is used to easily create and populate messages
  # @see Message
  class MessageBuilder
    # Convenience method that yields a new builder, populates defaults and returns the newly
    # built message instance
    #
    # @yield [MessageBuilder]
    # @return [Message]
    def self.build
      builder = new

      yield builder if block_given?

      builder.populate_defaults
      builder.build
    end

    # @return [String]
    attr_accessor :id

    # @return [Hash]
    attr_accessor :metadata

    # @return [Object]
    attr_accessor :payload

    # @return [Time]
    attr_accessor :timestamp

    # @return [Message]
    def build
      Message.new id, metadata, payload, timestamp
    end

    # @return [undefined]
    def populate_defaults
      @id ||= Synapse.identifier_factory.generate
      @metadata ||= Hash.new
      @timestamp ||= Time.now
    end
  end # MessageBuilder
end
