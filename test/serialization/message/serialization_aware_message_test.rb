require 'test_helper'

module Synapse
  module Serialization
    class SerializationAwareDomainEventMessageTest < Test::Unit::TestCase
      should 'delegate fields to the original message' do
        message = Domain::DomainEventMessage.build do |builder|
          builder.payload = Object.new
          builder.aggregate_id = 123
          builder.sequence_number = 0
        end

        aware = SerializationAwareDomainEventMessage.new message

        # EventMessage
        assert_same message.id, aware.id
        assert_same message.metadata, aware.metadata
        assert_same message.payload, aware.payload
        assert_same message.timestamp, aware.timestamp

        # DomainEventMessage
        assert_same message.aggregate_id, aware.aggregate_id
        assert_same message.sequence_number, aware.sequence_number
      end

      should 'cache serialization operations' do
        message = Domain::DomainEventMessage.build do |builder|
          builder.payload = Object.new
          builder.aggregate_id = 123
          builder.sequence_number = 0
        end

        aware = SerializationAwareDomainEventMessage.new message

        converter_factory = ConverterFactory.new

        serializer_a = MarshalSerializer.new converter_factory
        serializer_b = MarshalSerializer.new converter_factory

        [:serialize_metadata, :serialize_payload].each do |method|
          serialized_a = aware.send method, serializer_a, String
          serialized_b = aware.send method, serializer_a, String
          serialized_c = aware.send method, serializer_b, String

          assert_same serialized_a, serialized_b
          refute_same serialized_a, serialized_c
        end
      end

      should 'not further wrap messages that are already serialization aware' do
        message = Domain::DomainEventMessage.build

        aware = SerializationAwareDomainEventMessage.decorate message
        new_aware = SerializationAwareDomainEventMessage.decorate aware

        assert_same aware, new_aware
      end

      should 'wrap messages that are duplicated to add metadata' do
        message = Domain::DomainEventMessage.build do |builder|
          builder.metadata = { foo: 0 }
        end

        aware = SerializationAwareDomainEventMessage.new message
        new_aware = aware.and_metadata Hash.new

        assert_same new_aware, aware

        new_aware = aware.and_metadata bar: 1

        assert new_aware.is_a? SerializationAwareDomainEventMessage
      end

      should 'wrap messages that are duplicated to replace metadata' do
        message = Domain::DomainEventMessage.build do |builder|
          builder.metadata = { foo: 0 }
        end

        aware = SerializationAwareDomainEventMessage.new message
        new_aware = aware.with_metadata foo: 0

        assert_same new_aware, aware

        new_aware = aware.with_metadata bar: 1

        assert new_aware.is_a? SerializationAwareDomainEventMessage
      end
    end
  end
end
