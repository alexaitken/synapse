require 'spec_helper'

module Synapse
  module Serialization
    
    describe FixedRevisionResolver do
      it 'provides a fixed revision' do
        revision = 1
        
        resolver = FixedRevisionResolver.new revision
        resolver.revision_of(Array).should == revision.to_s
      end
    end
    
  end
end
