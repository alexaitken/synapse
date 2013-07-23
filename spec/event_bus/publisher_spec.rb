require 'spec_helper'

module Synapse
  module EventBus

    describe EventPublisher do
      it 'wraps events in messages before they are published' do
        event_bus = Object.new

        mock(event_bus).publish(is_a(Domain::EventMessage)) do |message|
          message.payload.should be_a(TestEvent)
        end

        publisher = ExampleEventPublisher.new
        publisher.event_bus = event_bus
        publisher.do_something
      end
    end

    class ExampleEventPublisher
      include EventPublisher

      def do_something
        publish_event TestEvent.new
      end
    end

    class TestEvent; end

  end
end
