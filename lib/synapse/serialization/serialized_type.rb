module Synapse
  module Serialization
    class SerializedType
      include Adamantium
      include Equalizer.new(:name, :revision)

      # @return [String]
      attr_reader :name

      # @return [String]
      attr_reader :revision

      # @param [String] name
      # @param [String] revision
      # @return [undefined]
      def initialize(name, revision = nil)
        @name = name
        @revision = revision.to_s
      end

      # @return [String]
      def inspect
        "<#{@name}, revision #{@revision}>"
      end
    end # SerializedType
  end # Serialization
end
