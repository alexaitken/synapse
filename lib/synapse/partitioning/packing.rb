module Synapse
  module Partitioning
    # Represents a mechanism for packing a message into a string so that it can be either stored
    # in a file or passed over a transport mechanism to be unpacked at the receiver
    #
    # This implementation simply returns the message as-is
    class MessagePacker
      # @param [Message] unpacked
      # @return [String]
      def pack_message(unpacked)
        unpacked
      end
    end

    # Represents a mechanism for unpacking a message that has been packed for storage in a file
    # or transport from a producer
    #
    # This implementation simply returns the message as-is
    class MessageUnpacker
      # @param [String] packed
      # @return [Message]
      def unpack_message(packed)
        packed
      end
    end
  end
end
