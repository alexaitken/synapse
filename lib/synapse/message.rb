module Synapse
  # Representation of a message containing a payload and metadata
  #
  # Instead of using this class directly, it is recommended to use a subclass specifically
  # for commands, events or domain events.
  #
  # Two messages with the same identifier should be interpreted as different representations
  # of the same conceptual message. In such case, the metadata may be different for both
  # representations. The payload *may* be identical.
  class Message
    # @return [String] Unique identifier of this message
    attr_accessor :id

    # @return [Hash] Metadata attached to this message by the application
    attr_accessor :metadata

    # @return [Object] The payload of this message; examples include commands and events
    attr_accessor :payload

    # @yield [Message]
    # @return [undefined]
    def initialize
      yield self if block_given?

      populate_default
      freeze
    end

    # Returns the class of the payload of this message; use this instead of calling payload
    # and class, in case of lazily deserializing messages.
    #
    # @return [Class]
    def payload_type
      @payload.class
    end

    # Returns a copy of this message with the given metadata merged in
    #
    # @param [Hash] metadata
    # @return [Message]
    def and_metadata(metadata)
      self.class.new do |message|
        populate_duplicate message, @metadata.merge(metadata)
      end
    end

    # Returns a copy of this message with the metadata replaced with the given metadata
    #
    # @param [Hash] metadata
    # @return [Message]
    def with_metadata(metadata)
      self.class.new do |message|
        populate_duplicate message, metadata
      end
    end

    # Freezes this message object, along with its metadata and payload
    # @return [undefined]
    def freeze
      super
      @metadata.freeze
      @payload.freeze
    end

  protected

    # Populates the default values of this message
    # @return [undefined]
    def populate_default
      @id ||= IdentifierFactory.instance.generate
      @metadata ||= Hash.new
    end

    # Populates a duplicated message with attributes from this method
    #
    # @param [Message] message
    # @param [Hash] metadata
    # @return [undefined]
    def populate_duplicate(message, metadata)
      message.id = @id
      message.metadata = metadata
      message.payload = @payload
    end
  end
end
