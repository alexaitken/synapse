require 'spec_helper'

module Synapse
  module EventBus

    describe MappingEventListener do
      subject do
        ExampleMappingEventListener.new
      end

      it 'uses the correct handler when notified of an events' do
        event = Domain::EventMessage.build do |builder|
          builder.payload = TestEvent.new
        end

        subject.notify event

        subject.handled.should be_true

        event = Domain::EventMessage.build do |builder|
          builder.payload = TestSubEvent.new
        end

        subject.notify event

        subject.sub_handled.should be_true
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
