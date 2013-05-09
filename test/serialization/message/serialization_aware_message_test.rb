require 'test_helper'

module Synapse
  module Serialization
    class SerializationAwareDomainEventMessageTest < Test::Unit::TestCase
      def test_delegation
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

      def test_caching
        message = Domain::DomainEventMessage.build do |builder|
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

          assert_same serialized_a, serialized_b
          refute_same serialized_a, serialized_c
        end
      end

      def test_decorate
        message = Domain::DomainEventMessage.build

        aware = SerializationAwareDomainEventMessage.decorate message
        new_aware = SerializationAwareDomainEventMessage.decorate aware

        assert_same aware, new_aware
      end

      def test_and_metadata
        message = Domain::DomainEventMessage.build do |builder|
          builder.metadata = { foo: 0 }
        end

        aware = SerializationAwareDomainEventMessage.new message
        new_aware = aware.and_metadata Hash.new

        assert_same new_aware, aware

        new_aware = aware.and_metadata bar: 1

        assert new_aware.is_a? SerializationAwareDomainEventMessage
      end

      def test_with_metadata
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
