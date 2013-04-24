module Synapse
  module Serialization
    # Implementation of a serializer that uses the built-in marshaling library
    #
    # Note that this serializer is not necessarily the fastest serializer available, nor is it
    # flexible. Output is binary and difficult to modify, which means upcasting is not possible
    # when using this serializer.
    class MarshalSerializer < Serializer
      # This serializer doesn't provide any configuration options

    protected

      # @param [Object] content
      # @return [Object]
      def perform_serialize(content)
        Marshal.dump content
      end

      # @param [Object] content
      # @param [Class] type
      # @return [Object]
      def perform_deserialize(content, type)
        Marshal.load content
      end

      # @return [Class]
      def native_content_type
        String
      end
    end
  end
end
