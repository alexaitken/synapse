require 'spec_helper'

module Synapse

  describe MessagePacker do
    it 'can pack and unpack messages' do
      cf = Serialization::ConverterFactory.new
      serializer = Serialization::MarshalSerializer.new cf

      packer = MessagePacker.new serializer

      message = Domain::DomainEventMessage.build do |builder|
        builder.metadata = { foo: 0, bar: 1 }
        builder.payload = { baz: 2, qux: 3 }
        builder.aggregate_id = SecureRandom.uuid
        builder.sequence_number = 123
      end

      io = StringIO.new
      packer.write io, message

      io.rewind

      unpacked = packer.read io

      unpacked.should be_a(Serialization::SerializedDomainEventMessage)

      unpacked.id.should == message.id
      unpacked.metadata.should == message.metadata
      unpacked.payload.should == message.payload
      unpacked.payload_type.should == Hash
      unpacked.timestamp.to_f.should == message.timestamp.to_f
      unpacked.aggregate_id.should == message.aggregate_id
      unpacked.sequence_number.should == message.sequence_number
    end
  end

end
