module Synapse
  module Partitioning
    extend ActiveSupport::Autoload

    # Optional queues
    autoload :AMQP

    autoload :MemoryQueueReader
    autoload :MemoryQueueWriter

    # Optional message packing
    autoload :JsonMessagePacker, 'synapse/partitioning/packing/json_packer'
    autoload :JsonMessageUnpacker, 'synapse/partitioning/packing/json_unpacker'
  end
end

require 'synapse/partitioning/message_receipt'
require 'synapse/partitioning/packing'
require 'synapse/partitioning/queue_reader'
require 'synapse/partitioning/queue_writer'
