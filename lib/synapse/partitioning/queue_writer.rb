module Synapse
  module Partitioning
    # @abstract
    class QueueWriter
      # @param [Object] packed
      # @param [Message] unpacked
      # @return [undefined]
      def put_message(packed, unpacked); end
    end
  end
end
