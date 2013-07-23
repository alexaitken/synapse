require 'spec_helper'

module Synapse
  module Command

    describe SerializationOptimizingInterceptor do
      it 'registers a serialization optimizing listener to the current unit of work' do
        interceptor = SerializationOptimizingInterceptor.new

        command = CommandMessage.build
        chain = Object.new
        unit = Object.new
        result = Object.new

        mock(chain).proceed(command) do
          result
        end
        mock(unit).register_listener(is_a(SerializationOptimizingListener))

        interceptor.intercept(command, unit, chain).should be(result)
      end
    end

    describe SerializationOptimizingListener do
      it 'wraps event messages with serialization aware event messages' do
        listener = SerializationOptimizingListener.new
        unit = Object.new

        event = Domain::DomainEventMessage.build
        decorated = listener.on_event_registered unit, event
        decorated.should be_a(Serialization::SerializationAwareDomainEventMessage)

        event = Domain::EventMessage.build
        decorated = listener.on_event_registered unit, event
        decorated.should be_a(Serialization::SerializationAwareEventMessage)
      end
    end

  end
end
