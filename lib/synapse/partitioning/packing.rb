module Synapse
  module Partitioning
    class MessagePacker
      # @param [Message] unpacked
      # @return [String]
      def pack_message(unpacked); end
    end

    class MessageUnpacker
      # @param [String] packed
      # @return [Message]
      def unpack_message(message); end
    end
  end
end
