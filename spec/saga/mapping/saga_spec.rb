require 'spec_helper'
require 'saga/mapping/fixtures'

module Synapse
  module Saga

    describe MappingSaga do
      before do
        @saga = OrderSaga.new
      end

      it 'uses the correct handler when notified of an event' do
        event = Domain::EventMessage.build do |builder|
          builder.payload = OrderCreated.new 123
        end

        @saga.handle event
        @saga.handled.should == 1
      end

      it 'uses mapping attributes to determine when to mark itself as finished' do
        event = Domain::EventMessage.build do |builder|
          builder.payload = OrderCanceled.new 123
        end

        @saga.handle event
        @saga.handled.should == 1
        expect(@saga.active?).to be_false
      end
    end

  end
end
