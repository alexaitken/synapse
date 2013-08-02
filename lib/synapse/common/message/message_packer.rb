module Synapse
  # @api public
  class MessagePacker
    # @param [Serialization::Serializer] serializer
    # @return [undefined]
    def initialize(serializer)
      @serializer = Serialization::MessageSerializer.new serializer
    end

    # @param [#read] io
    # @return [Serialization::SerializedMessage]
    def read(io)
      record = MessageRecord.read io

      if record.command?
        builder_type = Serialization::SerializedCommandMessage.builder
      elsif record.domain_event?
        builder_type = Serialization::SerializedDomainEventMessage.builder
      else
        builder_type = Serialization::SerializedEventMessage.builder
      end

      timestamp = Time.at record.timestamp

      serialized_metadata = Serialization::SerializedMetadata.new record.metadata, String
      serialized_payload = Serialization::SerializedObject.build record.payload, String,
        record.payload_type, record.payload_revision

      builder_type.build do |builder|
        builder.id = record.id
        builder.metadata = Serialization::LazyObject.new serialized_metadata, @serializer
        builder.payload = Serialization::LazyObject.new serialized_payload, @serializer
        builder.timestamp = timestamp

        if record.domain_event?
          builder.aggregate_id = record.aggregate_id
          builder.sequence_number = record.sequence_number
        end
      end
    end

    # @param [#write] io
    # @param [Message] message
    # @return [undefined]
    def write(io, message)
      serialized_metadata = @serializer.serialize_metadata message, String
      serialized_payload = @serializer.serialize_payload message, String

      record = MessageRecord.new

      record.type = MessageRecordType.from_class message.class
      record.id = message.id
      record.metadata = serialized_metadata.content
      record.payload = serialized_payload.content
      record.payload_type = serialized_payload.type.name
      record.payload_revision = serialized_payload.type.revision || String.new
      record.timestamp = message.timestamp.to_f

      if record.domain_event?
        record.aggregate_id = message.aggregate_id.to_s
        record.sequence_number = message.sequence_number
      end

      record.write io
    end
  end # MessagePacker
end
