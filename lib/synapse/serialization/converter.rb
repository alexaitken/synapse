module Synapse
  module Serialization
    module Converter
      include AbstractType

      # @param [Hash] options
      # @return [undefined]
      def initialize(options = {})
        @options = options
      end

      # @param [SerializedObject] original
      # @return [SerializedObject]
      def convert(original)
        SerializedObject.new(convert_content(original.content), target_type, original.type)
      end

      # @param [Object] original
      # @return [Object]
      abstract_method :convert_content

      # @return [Class]
      abstract_method :source_type

      # @return [Class]
      abstract_method :target_type
    end # Converter
  end # Serialization
end
