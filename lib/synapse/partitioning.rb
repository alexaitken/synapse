module Synapse
  module Partitioning
    extend ActiveSupport::Autoload

    autoload :MessageReceipt
    autoload :QueueReader
    autoload :QueueWriter

    autoload :MemoryQueueReader
    autoload :MemoryQueueWriter

    autoload_at 'synapse/partitioning/packing' do
      autoload :MessagePacker
      autoload :MessageUnpacker
    end

    autoload :JsonMessagePacker, 'synapse/partitioning/packing/json_packer'
    autoload :JsonMessageUnpacker, 'synapse/partitioning/packing/json_unpacker'

    module AMQP
      extend ActiveSupport::Autoload

      autoload :AMQPQueueReader
      autoload :AMQPQueueWriter

      autoload_at 'synapse/partitioning/amqp/key_resolver' do
        autoload :RoutingKeyResolver
        autoload :ModuleRoutingKeyResolver
      end
    end
  end
end
