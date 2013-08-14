require 'spec_helper'
require 'saga/routed/fixtures'

module Synapse
  module Saga

    describe RoutedSaga do
      subject {
        OrderSaga.new
      }

      it 'uses the correct handler when notified of an event' do
        event = Event.build_message do |builder|
          builder.payload = OrderCreated.new 123
        end

        subject.handle event
        subject.handled.should == 1
      end

      it 'uses mapping attributes to determine when to mark itself as finished' do
        event = Event.build_message do |builder|
          builder.payload = OrderCanceled.new 123
        end

        subject.handle event
        subject.handled.should == 1
        subject.should_not be_active
      end
    end

  end
end
