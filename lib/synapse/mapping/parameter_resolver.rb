module Synapse
  module Mapping
    class ParameterResolver
      include AbstractType

      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      abstract_method :can_resolve?

      # @param [Message] message
      # @return [Object]
      abstract_method :resolve
    end # ParameterResolver

    class PayloadParameterResolver < ParameterResolver
      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      def can_resolve?(index, name)
        index == 0
      end

      # @param [Message] message
      # @return [Object]
      def resolve(message)
        message.payload
      end
    end # PayloadParameterResolver

    class MessageParameterResolver < ParameterResolver
      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      def can_resolve?(index, name)
        :message == name
      end

      # @param [Message] message
      # @return [Object]
      def resolve(message)
        message
      end
    end # MessageParameterResolver

    class TimestampParameterResolver < ParameterResolver
      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      def can_resolve?(index, name)
        :timestamp == name
      end

      # @param [Message] message
      # @return [Object]
      def resolve(message)
        message.timestamp
      end
    end # TimestampParameterResolver

    class MetadataParameterResolver < ParameterResolver
      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      def can_resolve?(index, name)
        :metadata == name
      end

      # @param [Message] message
      # @return [Object]
      def resolve(message)
        message.metadata
      end
    end # MetadataParameterResolver

    class AggregateIdParameterResolver < ParameterResolver
      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      def can_resolve?(index, name)
        :aggregate_id == name
      end

      # @param [Message] message
      # @return [Object]
      def resolve(message)
        message.aggregate_id
      end
    end # AggregateIdParameterResolver

    class SequenceNumberParameterResolver < ParameterResolver
      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      def can_resolve?(index, name)
        :sequence_number == name
      end

      # @param [Message] message
      # @return [Object]
      def resolve(message)
        message.sequence_number
      end
    end # SequenceNumberParameterResolver

    class CurrentUnitParameterResolver < ParameterResolver
      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      def can_resolve?(index, name)
        [:unit, :current_unit, :uow, :current_uow].include? name
      end

      # @param [Message] message
      # @return [Object]
      def resolve(message)
        UnitOfWork.current
      end
    end # CurrentUnitParameterResolver

    class ResourceParameterResolver < ParameterResolver
      # @param [Object] resource
      # @param [Symbol...] names
      # @return [undefined]
      def initialize(resource, *names)
        @resource = resource
        @names = names
      end

      # @param [Integer] index
      # @param [Symbol] name
      # @return [Boolean]
      def can_resolve?(index, name)
        @names.include? name
      end

      # @param [Message] message
      # @return [Object]
      def resolve(message)
        @resource
      end
    end # ResourceParameterResolver
  end # Mapping
end
