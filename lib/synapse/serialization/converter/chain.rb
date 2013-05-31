module Synapse
  module Serialization
    # Converter implementation that chains together two or more converters
    class ConverterChain
      include Converter

      # @return [Array<Converter>]
      attr_reader :delegates

      # @return [Class]
      attr_reader :source_type

      # @return [Class]
      attr_reader :target_type

      # @param [Array<Converter>] delegates
      # @return [undefined]
      def initialize(delegates)
        @delegates = delegates
        @source_type = delegates.first.source_type
        @target_type = delegates.last.target_type
      end

      # @param [SerializedObject] original
      # @return [SerializedObject]
      def convert(original)
        intermediate = original
        @delegates.each do |delegate|
          intermediate = delegate.convert intermediate
        end
        intermediate
      end

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        intermediate = original
        @delegates.each do |delegate|
          intermediate = delegate.convert_content intermediate
        end
        intermediate
      end
    end # ConverterChain
  end # Serialization
end
