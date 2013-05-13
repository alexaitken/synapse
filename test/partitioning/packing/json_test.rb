require 'test_helper'

module Synapse
  module Partitioning

    class JsonPackingTest < Test::Unit::TestCase
      def setup
        @converter_factory = Serialization::ConverterFactory.new
        @serializer = Serialization::MarshalSerializer.new @converter_factory
        @packer = JsonMessagePacker.new @serializer
        @unpacker = JsonMessageUnpacker.new @serializer
      end

      def test_packing
        message = Domain::DomainEventMessage.build do |builder|
          builder.metadata = { foo: 0 }
          builder.payload = { bar: 1 }
          builder.aggregate_id = '123'
          builder.sequence_number = 1
        end

        packed = @packer.pack_message message
        unpacked = @unpacker.unpack_message packed

        assert_equal message.id, unpacked.id
        assert_equal message.metadata, unpacked.metadata
        assert_equal message.payload, unpacked.payload
        assert_equal message.timestamp.to_i, unpacked.timestamp.to_i
        assert_equal message.aggregate_id, unpacked.aggregate_id
        assert_equal message.sequence_number, unpacked.sequence_number
      end

      def test_type_packing
        [Command::CommandMessage, Domain::EventMessage, Domain::DomainEventMessage].each do |type|
          message = type.build
          packed = @packer.pack_message message
          unpacked = @unpacker.unpack_message packed

          assert type === unpacked
        end
      end

      def test_unknown_type
        message = Message.build

        assert_raise ArgumentError do
          @packer.pack_message message
        end

        packed = {
          message_type: :message
        }
        packed = JSON.dump packed

        assert_raise ArgumentError do
          @unpacker.unpack_message packed
        end
      end
    end

  end
end
