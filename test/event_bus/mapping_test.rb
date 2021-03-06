require 'test_helper'

module Synapse
  module EventBus

    class MappingEventListenerTest < Test::Unit::TestCase
      should 'use the correct handler when notified of an events' do
        listener = ExampleMappingEventListener.new

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

    class ExampleMappingEventListener
      include MappingEventListener

      attr_accessor :handled, :sub_handled

      map_event TestEvent do |event, message|
        raise ArgumentError unless TestEvent === event
        raise ArgumentError unless Domain::EventMessage === message

        @handled = true
      end

      map_event TestSubEvent, :to => :on_sub

      def on_sub(event)
        @sub_handled = true
      end
    end

  end
end
