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
        self.class === other and
          other.name == @name and
          other.revision == @revision
      end

      alias eql? ==

      def hash
        @name.hash ^ @revision.hash
      end
    end
  end
end