module Synapse
  module Partitioning
    # Implementation of a message packer that serializes the metadata and payload of any
    # message and then serializes the entire message so it can go onto the wire.
    class JsonMessagePacker < MessagePacker
      # @param [Serializer] serializer
      # @return [undefined]
      def initialize(serializer)
        @serializer = serializer

        @serialization_target = String
        # Ideally, we want to serialize the metadata and payload to hashes so that we don't
        # duplicate serialization while serializing the message as a whole to a string
        if serializer.can_serialize_to? Hash
          @serialization_target = Hash
        end
      end

      # @param [Message] unpacked
      # @return [String]
      def pack_message(unpacked)
        message_type = type_for unpacked

        metadata = @serializer.serialize unpacked.metadata, @serialization_target
        payload = @serializer.serialize unpacked.payload, @serialization_target

        packed = {
          message_type: message_type,
          id: unpacked.id,
          metadata: metadata.content,
          payload: payload.content,
          payload_type: payload.type.name,
          payload_revision: payload.type.revision
        }

        if [:event, :domain_event].include? message_type
          pack_event unpacked, packed
        end

        if :domain_event == message_type
          pack_domain_event unpacked, packed
        end

        JSON.dump packed
      end

    private

      # Packs additional attributes specific to event messages
      #
      # @param [EventMessage] unpacked
      # @param [Hash] packed
      # @return [undefined]
      def pack_event(unpacked, packed)
        additional = {
          timestamp: unpacked.timestamp.to_i
        }
        packed.merge! additional
      end

      # Packs additional attributes specific to domain event messages
      #
      # @param [DomainEventMessage] unpacked
      # @param [Hash] packed
      # @return [undefined]
      def pack_domain_event(unpacked, packed)
        additional = {
          aggregate_id: unpacked.aggregate_id.to_s,
          sequence_number: unpacked.sequence_number
        }
        packed.merge! additional
      end

      # Returns the packed type for the given message
      #
      # @raise [ArgumentError] If the given message isn't supported by this packer
      # @param [Message] unpacked
      # @return [Symbol]
      def type_for(unpacked)
        case unpacked
        when Command::CommandMessage
          :command
        when Domain::DomainEventMessage
          :domain_event
        when Domain::EventMessage
          :event
        else
          raise ArgumentError, 'Unknown message type'
        end
      end
    end # JsonMessagePacker
  end # Partitioning
end
