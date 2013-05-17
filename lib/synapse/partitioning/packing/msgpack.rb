require 'msgpack'

module Synapse
  module Partitioning
    # Message packer that packs and serializes a message into msgpack
    class MessagePackMessagePacker < HashMessagePacker
      # @param [Message] unpacked
      # @return [String]
      def pack_message(unpacked)
        MessagePack.pack to_hash unpacked
      end
    end # MessagePackMessagePacker

    # Message unpacker that deserializes a packed message from msgpack and then unpacks it
    class MessagePackMessageUnpacker < HashMessageUnpacker
      # @param [String] packed
      # @return [Message]
      def unpack_message(packed)
        from_hash MessagePack.unpack packed
      end
    end # MessagePackMessageUnpacker
  end # Partitioning
end
