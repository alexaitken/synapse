module Synapse
  module Partitioning
    # Implementation of a message unpacker that unpacks messages that come off the wire in the
    # format described by JsonMessagePacker
    class JsonMessageUnpacker < MessageUnpacker
      # @param [Serializer] serializer
      # @return [undefined]
      def initialize(serializer)
        @serializer = serializer
      end

      # @param [String] packed
      # @return [Message]
      def unpack_message(message)
        packed = JSON.load message
        packed.symbolize_keys!

        message_type = packed.fetch(:message_type).to_sym
        builder = builder_for(message_type).new

        builder.id = packed.fetch :id
        builder.metadata = deserialize_metadata packed
        builder.payload = deserialize_payload packed

        if [:event, :domain_event].include? message_type
          timestamp = packed.fetch :timestamp
          builder.timestamp = Time.at timestamp
        end

        if :domain_event == message_type
          builder.aggregate_id = packed.fetch :aggregate_id
          builder.sequence_number = packed.fetch :sequence_number
        end

        builder.build
      end

    private

      # @param [Hash] packed
      # @return [Hash]
      def deserialize_metadata(packed)
        content = packed.fetch :metadata
        @serializer.deserialize Serialization::SerializedMetadata.new content, content.class
      end

      # @param [Hash] packed
      # @return [Object]
      def deserialize_payload(packed)
        content = packed.fetch :payload
        name = packed.fetch :payload_type
        revision = packed.fetch :payload_revision

        serialized_type = Serialization::SerializedType.new name, revision
        serialized_object = Serialization::SerializedObject.new content, content.class, serialized_type

        @serializer.deserialize serialized_object
      end

      # @param [Symbol] type
      # @return [Class]
      def builder_for(type)
        case type
        when :command
          Command::CommandMessage.builder
        when :domain_event
          Domain::DomainEventMessage.builder
        when :event
          Domain::EventMessage.builder
        else
          raise ArgumentError, 'Unknown message type'
        end
      end
    end # JsonMessageUnpacker
  end # Partitioning
end # Synapse
