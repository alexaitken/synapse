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
      before do
        cf = ConverterFactory.new
        @serializer_a = MarshalSerializer.new cf
        @serializer_b = MarshalSerializer.new cf
      end

      it 'lazily deserializes metadata and payload' do
        metadata = { foo: 0 }
        payload = { bar: 1 }

        metadata_serialized = @serializer_a.serialize metadata, String
        payload_serialized = @serializer_a.serialize payload, String

        metadata_lazy = LazyObject.new metadata_serialized, @serializer_a
        payload_lazy = LazyObject.new payload_serialized, @serializer_a

        message = SerializedDomainEventMessage.build do |builder|
          builder.metadata = metadata_lazy
          builder.payload = payload_lazy
        end
        
        expect(message.serialized_metadata.deserialized?).to be_false
        message.metadata.should == metadata
        expect(message.serialized_metadata.deserialized?).to be_true
        
        message.payload_type.should == Hash
        expect(message.serialized_payload.deserialized?).to be_false
        message.payload.should == payload
        expect(message.serialized_payload.deserialized?).to be_true
        
        expect(message.serialize_metadata(@serializer_a, String)).to be(metadata_serialized)
        expect(message.serialize_payload(@serializer_a, String)).to be(payload_serialized)
        
        expect(message.serialize_metadata(@serializer_b, String)).to eql(metadata_serialized)
        expect(message.serialize_payload(@serializer_b, String)).to eql(payload_serialized)
      end

      it 'populates attributes of messages duplicated to add metadata' do
        metadata = { foo: 0 }
        payload = { bar: 1 }

        metadata_serialized = @serializer_a.serialize metadata, String
        metadata_lazy = LazyObject.new metadata_serialized, @serializer_a
        payload_serialized = @serializer_a.serialize metadata, String
        payload_lazy = LazyObject.new payload_serialized, @serializer_a

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

        new_message = message.and_metadata baz: 3

        merged = {
          foo: 0,
          baz: 3
        }

        new_message.metadata.should == merged
        ensure_equal_message_content message, new_message
      end

      it 'populates attributes of messages duplicated to replace metadata' do
        metadata = { foo: 0 }
        payload = { bar: 1 }

        metadata_serialized = @serializer_a.serialize metadata, String
        metadata_lazy = LazyObject.new metadata_serialized, @serializer_a
        payload_serialized = @serializer_a.serialize metadata, String
        payload_lazy = LazyObject.new payload_serialized, @serializer_a

        message = SerializedDomainEventMessage.build do |builder|
          builder.id = 1
          builder.metadata = metadata_lazy
          builder.payload = payload_lazy
          builder.timestamp = Time.now
          builder.aggregate_id = 2
          builder.sequence_number = 3
        end

        new_message = message.with_metadata foo: 0
        new_message.should be(message)

        replaced = {
          baz: 3
        }

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
