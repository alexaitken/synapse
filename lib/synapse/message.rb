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
    # Unique identifier of this message
    # @return [String]
    attr_reader :id

    # Metadata attached to this message by the application
    # @return [Hash]
    attr_reader :metadata

    # Payload of this message; examples include commands and events. A payload is expected to
    # be immutable to provide thread safety.
    #
    # @return [Object]
    attr_reader :payload

    # @param [String] id
    # @param [Hash] metadata
    # @param [Object] payload
    # @return [undefined]
    def initialize(id, metadata, payload)
      @id = id
      @metadata = metadata
      @payload = payload

      @metadata.freeze
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
      if metadata.empty?
        return self
      end

      builder = self.class.builder.new
      build_duplicate(builder, @metadata.merge(metadata))
      builder.build
    end

    # Returns a copy of this message with the metadata replaced with the given metadata
    #
    # @param [Hash] metadata
    # @return [Message]
    def with_metadata(metadata)
      if @metadata == metadata
        return self
      end

      builder = self.class.builder.new
      build_duplicate(builder, metadata)
      builder.build
    end

    # Yields a message builder that can be used to produce a message
    #
    # @see MessageBuilder#build
    # @yield [MessageBuilder]
    # @return [Message]
    def self.build(&block)
      builder.build(&block)
    end

    # Returns the type of builder that can be used to build this type of message
    # @return [Class]
    def self.builder
      MessageBuilder
    end

  protected

    # Populates a duplicated message with attributes from this message
    #
    # @param [MessageBuilder] message
    # @param [Hash] metadata
    # @return [undefined]
    def build_duplicate(builder, metadata)
      builder.id = @id
      builder.metadata = metadata
      builder.payload = @payload
    end
  end
end
