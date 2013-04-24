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
  # Messages are *not thread safe*, in an effort to keep complexity down
  class Message
    # @return [String] Unique identifier of this message
    attr_accessor :id

    # @return [Hash<String, Object>] Metadata attached to this message by the application
    attr_accessor :metadata

    # @return [Object] The payload of this message; examples include commands and events
    attr_accessor :payload

    def initialize
      yield self if block_given?

      @id ||= IdentifierFactory.instance.generate
      @metadata ||= Hash.new
    end
  end
end
