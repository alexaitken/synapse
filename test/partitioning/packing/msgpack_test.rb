require 'test_helper'
require 'partitioning/packing/pack_test_base'

module Synapse
  module Partitioning

    class MessagePackPackingTest < Test::Unit::TestCase
      include PackingTest

    protected

      def native_pack(unpacked)
        MessagePack.pack unpacked
      end

      def setup_packing
        skip 'msgpack not supported on JRuby' if defined? JRUBY_VERSION

        @packer = MessagePackMessagePacker.new @serializer
        @unpacker = MessagePackMessageUnpacker.new @serializer
      end
    end

  end
end
