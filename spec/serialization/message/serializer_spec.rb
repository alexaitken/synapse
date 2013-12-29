require 'spec_helper'

module Synapse
  module Serialization

    describe MessageSerializer do
      it 'delegates serialization to serializer if message not serialization aware' do
        delegate = Object.new
        serializer = MessageSerializer.new delegate

        metadata = {}
        payload = Object.new

        m = MessageBuilder.build do |b|
          b.metadata = metadata
          b.payload = payload
        end

        serialized_metadata = Object.new
        serialized_payload = Object.new

        mock(delegate).serialize(metadata, String) do
          serialized_metadata
        end
        mock(delegate).serialize(payload, String) do
          serialized_payload
        end

        serializer.serialize_metadata(m, String).should == serialized_metadata
        serializer.serialize_payload(m, String).should == serialized_payload
      end

      it 'delegates serialization to message if serialization aware' do
        delegate = Object.new
        serializer = MessageSerializer.new delegate

        stub_class = Class.new do
          include SerializationAware
        end

        stub = stub_class.new

        mock(stub).serialize_metadata(delegate, String)
        mock(stub).serialize_payload(delegate, String)

        serializer.serialize_metadata(stub, String)
        serializer.serialize_payload(stub, String)
      end
    end

  end
end

