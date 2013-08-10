module Synapse
  module Serialization
    class SerializedObject
      # Convenience method for creating serialized objects
      #
      # @param [Object] content
      # @param [Class] content_type
      # @param [String] type_name
      # @param [String] type_revision
      # @return [SerializedObject]
      def self.build(content, content_type, type_name, type_revision = nil)
        new(content, content_type, SerializedType.new(type_name, type_revision))
      end

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

      # @param [Object] other
      # @return [Boolean]
      def ==(other)
        instance_of?(other.class) &&
          @content == other.content &&
          @content_type == other.content_type &&
          @type == other.type
      end

      alias_method :eql?, :==

      # @return [Integer]
      def hash
        @content.hash ^ @content_type.hash ^ @type.hash
      end

      # @return [String]
      def inspect
        "<#{@type.inspect}, #{@content_type}>"
      end
    end # SerializedObject
  end # Serialization
end
