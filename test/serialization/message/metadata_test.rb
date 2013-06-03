require 'test_helper'

module Synapse
  module Serialization
    class SerializedMetadataTest < Test::Unit::TestCase
      should 'act like a serialized object' do
        content = 'test-metadata'
        content_type = String

        metadata = SerializedMetadata.new content, content_type

        assert_equal content, metadata.content
        assert_equal content_type, metadata.content_type
        assert_equal Hash.to_s, metadata.type.name
        assert_equal nil, metadata.type.revision
      end
    end
  end
end
