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
      def initialize(name, revision = nil)
        @name = name
        @revision = revision
      end

      def ==(other)
        self.class === other &&
          other.name == @name &&
          other.revision == @revision
      end

      alias_method :eql?, :==

      def hash
        @name.hash ^ @revision.hash
      end
    end # SerializedType
  end # Serialization
end
