module Synapse
  module Serialization
    # Represents a mechanism for converting content of one type to another type for the purposes
    # of serialization, deserialization and upcasting.
    module Converter
      extend ActiveSupport::Concern

      included do
        # @return [Class]
        class_attribute :source_type

        # @return [Class]
        class_attribute :target_type
      end

      module ClassMethods
        # @param [Class] source_type
        # @param [Class] target_type
        # @return [undefined]
        def converts(source_type, target_type)
          self.source_type = source_type
          self.target_type = target_type
        end
      end

      def initialize(options = {})
        @options = options
      end

      # @param [SerializedObject] original
      # @return [SerializedObject]
      def convert(original)
        SerializedObject.new(convert_content(original.content), target_type, original.type)
      end

      # @abstract
      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        raise NotImplementedError
      end
    end # Converter
  end # Serialization
end
