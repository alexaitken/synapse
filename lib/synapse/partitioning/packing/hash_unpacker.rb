module Synapse
  module Partitioning
    # Implementation of a message unpacker that unpacks messages that come off the wire in the
    # format described by HashMessagePacker
    # @abstract
    class HashMessageUnpacker < MessageUnpacker
      # @param [Serializer] serializer
      # @return [undefined]
      def initialize(serializer)
        @serializer = serializer
      end

    protected

      # @param [Hash] packed
      # @return [Message]
      def from_hash(packed)
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

      # Deserializes the metadata of the given packed message
      #
      # @param [Hash] packed
      # @return [Hash]
      def deserialize_metadata(packed)
        content = packed.fetch :metadata
        serialized_metadata = Serialization::SerializedMetadata.new content, content.class

        @serializer.deserialize serialized_metadata
      end

      # Deserializes the payload of the given packed message
      #
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

      # Returns the builder type for the given message type
      #
      # @raise [ArgumentError] If message type isn't supported by this unpacker
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
end
