require 'test_helper'

module Synapse
  class SerializationAwareMessageTest < Test::Unit::TestCase
    def setup
      @message = Message.build do |m|
        m.payload = Object.new
      end

      @serializer_a = Serialization::MarshalSerializer.new
      @serializer_b = Serialization::MarshalSerializer.new
    end

    def test_metadata_caching
      serialized_metadata_a = @message.serialize_metadata @serializer_a, String
      serialized_metadata_b = @message.serialize_metadata @serializer_a, String

      assert serialized_metadata_a.equal? serialized_metadata_b

      serialized_metadata_c = @message.serialize_metadata @serializer_b, String

      refute serialized_metadata_a.equal? serialized_metadata_c
    end

    def test_payload_caching
      serialized_payload_a = @message.serialize_payload @serializer_a, String
      serialized_payload_b = @message.serialize_payload @serializer_a, String

      assert serialized_payload_a.equal? serialized_payload_b

      serialized_payload_c = @message.serialize_payload @serializer_b, String

      refute serialized_payload_a.equal? serialized_payload_c
    end
  end
end
