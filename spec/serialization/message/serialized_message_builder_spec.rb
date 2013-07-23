require 'spec_helper'

module Synapse
  module Serialization

    describe SerializedDomainEventMessageBuilder do
      it 'builds a message from serialized domain event data' do
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

        expect(built.id).to eql(data.id)

        expect(built.serialized_metadata.serialized_object).to eql(data.metadata)
        expect(built.serialized_metadata.serializer).to eql(serializer)
        expect(built.serialized_payload.serialized_object).to eql(data.payload)
        expect(built.serialized_payload.serializer).to eql(serializer)

        expect(built.timestamp).to eql(data.timestamp)
        expect(built.aggregate_id).to eql(data.aggregate_id)
        expect(built.sequence_number).to eql(data.sequence_number)
      end
    end

    class StubSerializedDomainEventData < SerializedDomainEventData
      attr_accessor :id, :metadata, :payload, :timestamp, :aggregate_id, :sequence_number
    end

  end
end
