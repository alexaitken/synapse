require 'test_helper'

module Synapse
  module EventBus
    class EventPublisherTest < Test::Unit::TestCase
      def test_publish_event
        event_bus = Object.new

        mock(event_bus).publish(is_a(Domain::EventMessage)) do |message|
          assert message.payload.is_a? TestEvent
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
