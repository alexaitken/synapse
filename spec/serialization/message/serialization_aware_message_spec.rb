require 'spec_helper'

module Synapse
  module Serialization

    describe SerializationAwareDomainEventMessage do
      it 'delegates attributes to the original message' do
        message = Domain.build_message do |builder|
          builder.payload = Object.new
          builder.aggregate_id = 123
          builder.sequence_number = 0
        end

        aware = SerializationAwareDomainEventMessage.new message

        # EventMessage
        aware.id.should == message.id
        aware.metadata.should == message.metadata
        aware.payload.should == message.payload
        aware.timestamp.should == message.timestamp

        # DomainEventMessage
        aware.aggregate_id.should == message.aggregate_id
        aware.sequence_number.should == message.sequence_number
      end

      it 'caches serialization operations' do
        message = Domain.build_message do |builder|
          builder.payload = Object.new
          builder.aggregate_id = 123
          builder.sequence_number = 0
        end

        aware = SerializationAwareDomainEventMessage.new message

        serializer_a = MarshalSerializer.new
        serializer_b = MarshalSerializer.new

        [:serialize_metadata, :serialize_payload].each do |method|
          serialized_a = aware.send method, serializer_a, String
          serialized_b = aware.send method, serializer_a, String
          serialized_c = aware.send method, serializer_b, String

          serialized_a.should be(serialized_b)
          serialized_b.should_not be(serialized_c)
        end
      end

      it 'does not wrap messages that are already serialization aware' do
        message = Domain.build_message

        aware = SerializationAwareDomainEventMessage.decorate message
        new_aware = SerializationAwareDomainEventMessage.decorate aware

        new_aware.should be(aware)
      end

      it 'wraps messages that are duplicated to add metadata' do
        message = Domain.build_message do |builder|
          builder.metadata = Hash[:foo, 0]
        end

        aware = SerializationAwareDomainEventMessage.new message

        # Don't duplicate for empty metadata hashes
        new_aware = aware.and_metadata Hash.new
        new_aware.should be(aware)

        new_aware = aware.and_metadata bar: 1
        new_aware.should be_a(SerializationAwareDomainEventMessage)
      end

      it 'wraps messages that are duplicated to replace metadata' do
        message = Domain.build_message do |builder|
          builder.metadata = Hash[:foo, 0]
        end

        aware = SerializationAwareDomainEventMessage.new message

        # Don't duplicate when metadata is the same
        new_aware = aware.with_metadata Hash[:foo, 0]
        new_aware.should be(aware)

        new_aware = aware.with_metadata Hash[:bar, 1]
        new_aware.should be_a(SerializationAwareDomainEventMessage)
      end
    end

  end
end

