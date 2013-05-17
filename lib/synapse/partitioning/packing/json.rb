module Synapse
  module Partitioning
    # Message packer that packs and serializes a message into JSON
    class JsonMessagePacker < HashMessagePacker
      # @param [Message] unpacked
      # @return [String]
      def pack_message(unpacked)
        JSON.dump to_hash unpacked
      end
    end # JsonMessagePacker

    # Message unpacker that deserializes a packed message from JSON and then unpacks it
    class JsonMessageUnpacker < HashMessageUnpacker
      # @param [String] packed
      # @return [Message]
      def unpack_message(packed)
        from_hash JSON.load packed
      end
    end # JsonMessageUnpacker
  end # Partitioning
end
