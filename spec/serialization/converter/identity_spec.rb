require 'spec_helper'

module Synapse
  module Serialization

    describe IdentityConverter do
      it 'passes through objects unchanged' do
        converter = IdentityConverter.new Hash
        content = Hash.new

        converter.source_type.should == Hash
        converter.target_type.should == Hash
        converter.convert(content).should be(content)
        converter.convert_content(content).should be(content)
      end
    end

  end
end

