require 'spec_helper'

module Synapse
  module Serialization

    describe SerializedMetadata do
      it 'acts like a serialized object' do
        content = 'test-metadata'
        content_type = String

        metadata = SerializedMetadata.new content, content_type

        metadata.content.should == content
        metadata.content_type.should == content_type
        metadata.type.name.should == 'Hash'
        metadata.type.revision.should == ''
      end
    end

  end
end

