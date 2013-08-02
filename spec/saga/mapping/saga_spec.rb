require 'spec_helper'
require 'saga/mapping/fixtures'

module Synapse
  module Saga

    describe MappingSaga do
      subject do
        OrderSaga.new
      end

      it 'uses the correct handler when notified of an event' do
        event = Domain::EventMessage.build do |builder|
          builder.payload = OrderCreated.new 123
        end

        subject.handle event
        subject.handled.should == 1
      end

      it 'uses mapping attributes to determine when to mark itself as finished' do
        event = Domain::EventMessage.build do |builder|
          builder.payload = OrderCanceled.new 123
        end

        subject.handle event
        subject.handled.should == 1
        subject.should_not be_active
      end
    end

  end
end
