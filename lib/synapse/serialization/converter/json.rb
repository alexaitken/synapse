require 'json'

module Synapse
  module Serialization
    # Converter that converts a JSON string into a Ruby data structure
    class JsonToObjectConverter
      include Converter

      converts String, Object

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        JSON.parse original, @options
      end
    end

    # Converter that converts a Ruby data structure into a JSON string
    class ObjectToJsonConverter
      include Converter

      converts Object, String

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        JSON.generate original, @options
      end
    end
  end
end
