begin
  require 'ox'
rescue LoadError
  warn 'Ensure that Ox is installed before using the Ox serializer'
end

module Synapse
  module Serialization
    # Implementation of a serializer that uses the Optimized XML (Ox) marshaling library
    class OxSerializer < Serializer
      # @return [Hash] Options that will be passed to the Ox dump method
      attr_accessor :serialize_options

      protected

      # @param [Object] content
      # @return [Object]
      def perform_serialize(content)
        Ox.dump content, @serialize_options
      end

      # @param [Object] content
      # @param [Class] type
      # @return [Object]
      def perform_deserialize(content, type)
        Ox.parse_obj content
      end

      # @return [Class]
      def native_content_type
        String
      end
    end # OxSerializer
  end # Serialization
end
