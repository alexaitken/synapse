module Synapse
  module Serialization
    # Convenience implementation of serialized object containing metadata
    class SerializedMetadata < SerializedObject
      # @param [Object] content
      # @param [Class] content_type
      # @return [undefined]
      def initialize(content, content_type)
        super(content, content_type, SerializedType.new(Hash.to_s, nil))
      end
    end
  end
end
