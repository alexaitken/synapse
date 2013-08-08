module Synapse
  # Representation of a message containing a payload and metadata
  #
  # Instead of using this class directly, it is recommended to use a subclass specifically
  # for commands, events or domain events.
  #
  # Two messages with the same identifier should be interpreted as different representations
  # of the same conceptual message. In such case, the metadata may be different for both
  # representations. The payload *may* be identical.
  #
  # *Thread safety note*: Messages are designed to be immutable. As such, it is highly
  # unrecommended to modify the metadata or payload of a message directly. Instead, use
  # +and_metadata+ and +with_metadata+ to add additional metadata or replace existing metadata.
  #
  # @see MessageBuilder
  class Message
    # @param [Object] object
    # @return [Message]
    def self.as_message(object)
      unless object.is_a? self
        object = build do |builder|
          builder.payload = object
        end
      end

      object
    end

    # @see MessageBuilder#build
    # @yield [MessageBuilder]
    # @return [Message]
    def self.build(&block)
      builder.build &block
    end

    # @return [Class]
    def self.builder
      MessageBuilder
    end

    # @return [String] The identifier of this message
    attr_reader :id

    # @return [Hash] The application-specific metadata associated with this message
    attr_reader :metadata

    # @return [Object] The content of this message
    attr_reader :payload

    # @return [Time] The time when this message was created
    attr_reader :timestamp

    # @param [String] id
    # @param [Hash] metadata
    # @param [Object] payload
    # @param [Time] timestamp
    # @return [undefined]
    def initialize(id, metadata, payload, timestamp)
      @id = id
      @metadata = metadata
      @payload = payload
      @timestamp = timestamp
    end

    # Returns the type of payload contained in this message
    #
    # Semantically equal to calling +payload.class+, but implementations can choose to optimize
    # by lazily deserializing messages.
    #
    # @return [Class]
    def payload_type
      @payload.class
    end

    # Returns a duplicate of this message, merging the metadata with the given metadata
    #
    # @param [Hash] metadata
    # @return [Message]
    def and_metadata(metadata)
      return self if metadata.empty?
      build_duplicate @metadata.merge metadata
    end

    # Returns a duplicate of this message, replacing the metadata with the given metadata
    #
    # @param [Hash] metadata
    # @return [Message]
    def with_metadata(metadata)
      return self if metadata == @metadata
      build_duplicate metadata
    end

    protected

    # @param [MessageBuilder] builder
    # @param [Hash] metadata
    # @return [undefined]
    def populate_duplicate(builder, metadata)
      builder.id = @id
      builder.metadata = metadata
      builder.payload = @payload
      builder.timestamp = @timestamp
    end

    private

    # @param [Hash] metadata
    # @return [Message]
    def build_duplicate(metadata)
      builder = self.class.builder.new
      populate_duplicate builder, metadata
      builder.build
    end
  end # Message
end
