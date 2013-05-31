require 'test_helper'

module Synapse
  module EventBus

    class WiringEventListenerTest < Test::Unit::TestCase
      should 'use the correct handler when notified of an events' do
        listener = ExampleWiringEventListener.new

        event = Domain::EventMessage.build do |builder|
          builder.payload = TestEvent.new
        end

        listener.notify event

        assert listener.handled

        event = Domain::EventMessage.build do |builder|
          builder.payload = TestSubEvent.new
        end

        listener.notify event

        assert listener.sub_handled
      end
    end

    class TestEvent; end
    class TestSubEvent < TestEvent; end

    class ExampleWiringEventListener
      include WiringEventListener

      attr_accessor :handled, :sub_handled

      wire TestEvent do |event|
        @handled = true
      end

      wire TestSubEvent do |event|
        @sub_handled = true
      end
    end

  end
end
