module Synapse
  module Partitioning
    # Receipt used to track messages taken off of a queue
    class MessageReceipt
      # @return [Object] The transport mechanism's record of the message
      attr_reader :tag

      # @return [Object] The packed message from the transport
      attr_reader :packed

      # @return [String] The name of the queue the message was read from
      attr_reader :queue_name

      # @param [Object] tag
      # @param [Object] packed
      # @param [String] queue_name
      # @return [undefined]
      def initialize(tag, packed, queue_name)
        @tag = tag
        @packed = packed
        @queue_name = queue_name
      end
    end
  end
end
