require 'test_helper'
require 'partitioning/packing/pack_test_base'

module Synapse
  module Partitioning

    class JsonPackingTest < Test::Unit::TestCase
      include PackingTest

    protected

      def native_pack(unpacked)
        JSON.dump unpacked
      end

      def setup_packing
        @packer = JsonMessagePacker.new @serializer
        @unpacker = JsonMessageUnpacker.new @serializer
      end
    end

  end
end
