require 'spec_helper'

module Synapse

  describe MessageBuilder do
    it 'populates unset message attributes with defaults' do
      message = MessageBuilder.build do |builder|
        builder.payload = Object.new
      end

      message.id.should_not be_empty
      message.metadata.should == {}
      message.timestamp.should be_a Time
    end
  end

end
