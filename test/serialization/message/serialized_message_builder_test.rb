require 'test_helper'

module Synapse
  module Serialization

    class SerializedDomainEventMessageBuilderTest < Test::Unit::TestCase
      def test_from_data
        builder = SerializedDomainEventMessageBuilder.new

        serializer = MarshalSerializer.new ConverterFactory.new

        data = StubSerializedDomainEventData.new
        data.id = 0
        data.metadata = SerializedObject.new(nil, nil, SerializedType.new(Object.to_s, nil))
        data.payload = SerializedObject.new(nil, nil, SerializedType.new(Object.to_s, nil))
        data.aggregate_id = 1
        data.sequence_number = 2

        builder.from_data data, serializer

        built = builder.build

        assert_equal data.id, built.id

        assert_equal data.metadata, built.serialized_metadata.serialized_object
        assert_equal serializer, built.serialized_metadata.serializer
        assert_equal data.payload, built.serialized_payload.serialized_object
        assert_equal serializer, built.serialized_payload.serializer

        assert_equal data.timestamp, built.timestamp
        assert_equal data.aggregate_id, built.aggregate_id
        assert_equal data.sequence_number, built.sequence_number
      end
    end

    class StubSerializedDomainEventData < SerializedDomainEventData
      attr_accessor :id, :metadata, :payload, :timestamp, :aggregate_id, :sequence_number
    end

  end
end
