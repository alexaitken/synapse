module Synapse
  module Mapping
    class MessageHandlerScore
      # @return [Integer]
      attr_reader :declaration_depth

      # @return [Integer]
      attr_reader :payload_depth

      # @return [String]
      attr_reader :payload_name

      # @param [Class] subject_type
      # @param [Class] payload_type
      # @return [undefined]
      def initialize(subject_type, payload_type)
        @declaration_depth = superclass_count subject_type
        @payload_depth = superclass_count payload_type
        @payload_name = payload_type.name
      end

      # @param [MessageHandlerScore] other
      # @return [Integer]
      def <=>(other)
        if other.declaration_depth != @declaration_depth
          other.declaration_depth <=> @declaration_depth
        elsif other.payload_depth != @payload_depth
          other.payload_depth <=> @payload_depth
        else
          other.payload_name <=> @payload_name
        end
      end

      # @param [MessageHandlerScore] other
      # @return [Boolean]
      def ==(other)
        other.instance_of?(self.class) &&
          other.declaration_depth == @declaration_depth &&
          other.payload_depth == @payload_depth &&
          other.payload_name == @payload_name
      end

      alias_method :eql?, :==

      # @return [Integer]
      def hash
        @declaration_depth.hash ^ @payload_depth.hash ^ @payload_name.hash
      end

      private

      # @param [Class] type
      # @return [Integer]
      def superclass_count(type)
        count = 0
        while type
          type = type.superclass
          count += 1
        end

        count
      end
    end # MessageHandlerScore
  end # Mapping
end
