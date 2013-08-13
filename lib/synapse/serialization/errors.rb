module Synapse
  module Serialization
    # Raised when conversion between two types is not supported
    class ConversionError < NonTransientError; end

    # Raised when an error occurs during serialization
    class SerializationError < NonTransientError; end

    # Raised when a serialized type can't be found in the current environment
    class UnknownSerializedTypeError < SerializationError; end
  end
end
