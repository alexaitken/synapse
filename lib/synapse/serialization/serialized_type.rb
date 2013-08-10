module Synapse
  module Serialization
    class SerializedType
      # @return [String]
      attr_reader :name

      # @return [String]
      attr_reader :revision

      # @param [String] name
      # @param [String] revision
      # @return [undefined]
      def initialize(name, revision)
        @name = name
        @revision = revision.to_s
      end

      # @param [Object] other
      # @return [Boolean]
      def ==(other)
        instance_of?(other.class) &&
          @name == other.name &&
          @revision == other.revision
      end

      alias_method :eql?, :==

      # @return [Integer]
      def hash
        @name.hash ^ @revision.hash
      end

      # @return [String]
      def inspect
        "<#{@name}, revision #{@revision}>"
      end
    end # SerializedType
  end # Serialization
end
