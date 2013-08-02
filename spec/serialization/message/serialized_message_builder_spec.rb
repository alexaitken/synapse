require 'spec_helper'

module Synapse
  module Serialization

    describe SerializedDomainEventMessageBuilder do
      it 'builds a message from serialized domain event data' do
        builder = SerializedDomainEventMessageBuilder.new

        serializer = MarshalSerializer.new ConverterFactory.new

        data = StubSerializedDomainEventData.new
        data.id = 0
        data.metadata = SerializedObject.build nil, nil, Object.name, nil
        data.payload = SerializedObject.build nil, nil, Object.name, nil
        data.aggregate_id = 1
        data.sequence_number = 2

        builder.from_data data, serializer

        built = builder.build

        built.id.should == data.id

        built.serialized_metadata.serialized_object.should == data.metadata
        built.serialized_metadata.serializer.should == serializer
        built.serialized_payload.serialized_object.should == data.payload
        built.serialized_payload.serializer.should == serializer

        built.timestamp.should == data.timestamp
        built.aggregate_id.should == data.aggregate_id
        built.sequence_number.should == data.sequence_number
      end
    end

    class StubSerializedDomainEventData < SerializedDomainEventData
      attr_accessor :id, :metadata, :payload, :timestamp, :aggregate_id, :sequence_number
    end

  end
end
