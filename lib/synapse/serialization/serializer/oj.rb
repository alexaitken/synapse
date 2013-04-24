require 'oj'

module Synapse
  module Serialization
    # Implementation of a serializer that uses the Optimized JSON (Oj) marshaling library
    class OjSerializer < Serializer
      # @return [Hash] Options that will be passed to the Oj dump method
      attr_accessor :serialize_options

      # @return [Hash] Options that will be passed to the Oj load method
      attr_accessor :deserialize_options

    protected

      # @param [Object] content
      # @return [Object]
      def perform_serialize(content)
        Oj.dump content, @serialize_options
      end

      # @param [Object] content
      # @param [Class] type
      # @return [Object]
      def perform_deserialize(content, type)
        Oj.load content, @deserialize_options
      end

      # @return [Class]
      def native_content_type
        String
      end
    end
  end
end
