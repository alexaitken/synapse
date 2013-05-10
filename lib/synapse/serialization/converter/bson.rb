require 'bson'

module Synapse
  module Serialization
    # Converter that converts an ordered hash from BSON into a regular Ruby hash
    class OrderedHashToHashConverter
      include Converter

      converts BSON::OrderedHash, Hash

      # @param [Object] original
      # @return [Object]
      def convert_content(original)
        converted = Hash.new

        original.each do |key, value|
          if value.is_a? BSON::OrderedHash
            value = convert_content value
          end

          converted[key] = value
        end

        converted
      end
    end
  end
end
