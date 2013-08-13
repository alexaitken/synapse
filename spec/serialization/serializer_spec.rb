require 'spec_helper'

module Synapse
  module Serialization

    describe Serializer do
      it 'uses a revision resolver when one is configured' do
        revision = '123'

        serializer = StubSerializer.new
        serializer.revision_resolver = FixedRevisionResolver.new revision

        type = serializer.type_for Object

        type.revision.should == revision
      end
    end

    class StubSerializer < Serializer; end

  end
end
