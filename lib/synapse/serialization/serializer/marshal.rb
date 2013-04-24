require 'oj'

module Synapse
  module Serialization
    # Implementation of a serializer that uses the built-in marshaling library
    class MarshalSerializer < Serializer
    protected

      # @param [Object] content
      # @return [Object]
      def perform_serialize(content)

      end

      # @param [Object] content
      # @param [Class] type
      # @return [Object]
      def perform_deserialize(content, type)

      end

      # @return [Class]
      def native_content_type
        String
      end
    end
  end
end
