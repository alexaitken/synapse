require 'json'

module Synapse
  module Serialization
    # Converter that converts a JSON string into a Ruby data structure
    class JsonToObjectConverter
      include Converter

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        JSON.parse original, @options
      end

      # @return [Class]
      def source_type
        String
      end

      # @return [Class]
      def target_type
        Object
      end
    end # JsonToObjectConverter

    # Converter that converts a Ruby data structure into a JSON string
    class ObjectToJsonConverter
      include Converter

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        JSON.generate original, @options
      end

      # @return [Class]
      def source_type
        Object
      end

      # @return [Class]
      def target_type
        String
      end
    end # ObjectToJsonConverter
  end # Serialization
end
