module Synapse
  module Serialization
    class SerializedObject
      # @return [Object]
      attr_reader :content

      # @return [Class]
      attr_reader :content_type

      # @return [SerializedType]
      attr_reader :type

      # @param [Object] content
      # @param [Class] content_type
      # @param [SerializedType] type
      # @return [undefined]
      def initialize(content, content_type, type)
        @content = content
        @content_type = content_type
        @type = type
      end

      def ==(other)
        self.class === other &&
          other.content == @content &&
          other.content_type == @content_type &&
          other.type == @type
      end

      alias_method :eql?, :==

      def hash
        @content.hash ^ @content_type.hash ^ @type.hash
      end
    end # SerializedObject
  end # Serialization
end
