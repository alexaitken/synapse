module Synapse
  module Partitioning
    extend ActiveSupport::Autoload

    # Optional queues
    autoload :AMQP
    autoload :MemoryQueueReader
    autoload :MemoryQueueWriter

    # Optional message packing
    autoload_at 'synapse/partitioning/packing/json' do
      autoload :JsonMessagePacker
      autoload :JsonMessageUnpacker
    end

    autoload_at 'synapse/partitioning/packing/msgpack' do
      autoload :MessagePackMessagePacker
      autoload :MessagePackMessageUnpacker
    end
  end
end

require 'synapse/partitioning/message_receipt'
require 'synapse/partitioning/packing'
require 'synapse/partitioning/queue_reader'
require 'synapse/partitioning/queue_writer'

require 'synapse/partitioning/packing/hash_packer'
require 'synapse/partitioning/packing/hash_unpacker'
