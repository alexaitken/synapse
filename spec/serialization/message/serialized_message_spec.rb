require 'spec_helper'

module Synapse
  module Serialization

    describe SerializedMessage do
      it 'provides a builder for serialized messages' do
        message = SerializedMessage.build do |builder|
          builder.should be_a(SerializedMessageBuilder)
        end
        message.should be_a(SerializedMessage)
      end
    end

    describe SerializedEventMessage do
      it 'provides a builder for serialized event messages' do
        message = SerializedEventMessage.build do |builder|
          builder.should be_a(SerializedEventMessageBuilder)
        end
        message.should be_a(SerializedEventMessage)
      end
    end

    describe SerializedDomainEventMessage do
      let(:serializer_a) { MarshalSerializer.new }
      let(:serializer_b) { MarshalSerializer.new }

      it 'lazily deserializes metadata and payload' do
        metadata = Hash[:foo, 0]
        payload = Hash[:bar, 1]

        metadata_serialized = serializer_a.serialize metadata, String
        payload_serialized = serializer_a.serialize payload, String

        metadata_lazy = LazyObject.new metadata_serialized, serializer_a
        payload_lazy = LazyObject.new payload_serialized, serializer_a

        message = SerializedDomainEventMessage.build do |builder|
          builder.metadata = metadata_lazy
          builder.payload = payload_lazy
        end

        message.serialized_metadata.should_not be_deserialized
        message.metadata.should == metadata
        message.serialized_metadata.should be_deserialized

        message.payload_type.should == Hash
        message.serialized_payload.should_not be_deserialized
        message.payload.should == payload
        message.serialized_payload.should be_deserialized

        message.serialize_metadata(serializer_a, String).should be(metadata_serialized)
        message.serialize_payload(serializer_a, String).should be(payload_serialized)

        message.serialize_metadata(serializer_b, String).should == metadata_serialized
        message.serialize_payload(serializer_b, String).should == payload_serialized
      end

      it 'populates attributes of messages duplicated to add metadata' do
        metadata = Hash[:foo, 0]
        payload = Hash[:bar, 1]

        metadata_serialized = serializer_a.serialize metadata, String
        metadata_lazy = LazyObject.new metadata_serialized, serializer_a
        payload_serialized = serializer_a.serialize metadata, String
        payload_lazy = LazyObject.new payload_serialized, serializer_a

        message = SerializedDomainEventMessage.build do |builder|
          builder.id = 1
          builder.metadata = metadata_lazy
          builder.payload = payload_lazy
          builder.timestamp = Time.now
          builder.aggregate_id = 2
          builder.sequence_number = 3
        end

        new_message = message.and_metadata Hash.new
        new_message.should be(message)

        new_message = message.and_metadata Hash[:baz, 3]

        merged = Hash[:foo, 0, :baz, 3]

        new_message.metadata.should == merged
        ensure_equal_message_content message, new_message
      end

      it 'populates attributes of messages duplicated to replace metadata' do
        metadata = Hash[:foo, 0]
        payload = Hash[:bar, 1]

        metadata_serialized = serializer_a.serialize metadata, String
        metadata_lazy = LazyObject.new metadata_serialized, serializer_a
        payload_serialized = serializer_a.serialize metadata, String
        payload_lazy = LazyObject.new payload_serialized, serializer_a

        message = SerializedDomainEventMessage.build do |builder|
          builder.id = 1
          builder.metadata = metadata_lazy
          builder.payload = payload_lazy
          builder.timestamp = Time.now
          builder.aggregate_id = 2
          builder.sequence_number = 3
        end

        new_message = message.with_metadata Hash[:foo, 0]
        new_message.should be(message)

        replaced = Hash[:baz, 3]

        new_message = message.with_metadata replaced

        new_message.metadata.should == replaced
        ensure_equal_message_content message, new_message
      end

    private

      def ensure_equal_message_content(expected, actual)
        actual.id.should == expected.id
        actual.serialized_payload.should == expected.serialized_payload
        actual.timestamp.should == expected.timestamp
        actual.aggregate_id.should == expected.aggregate_id
        actual.sequence_number.should == expected.sequence_number
      end
    end

  end
end

