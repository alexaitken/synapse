require 'spec_helper'
require 'serialization/fixtures'

module Synapse
  module Serialization

    describe MarshalSerializer do
      it 'supports serializing and deserializing content' do
        event = TestEvent.new 'derp', 'herp'

        serialized_obj = subject.serialize event, String
        deserialized = subject.deserialize serialized_obj

        deserialized.should == event
      end
    end

  end
end

