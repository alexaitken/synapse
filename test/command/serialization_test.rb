require 'test_helper'

module Synapse
  module Command

    class SerializationOptimizingInterceptorTest < Test::Unit::TestCase
      should 'register a serialization optimizing listener to the current unit of work' do
        interceptor = SerializationOptimizingInterceptor.new

        command = CommandMessage.build
        chain = Object.new
        unit = Object.new

        mock(chain).proceed(command)
        mock(unit).register_listener(is_a(SerializationOptimizingListener))

        interceptor.intercept(command, unit, chain)
      end
    end

    class SerializationOptimizingListenerTest < Test::Unit::TestCase
      should 'wrap event messages with serialization aware event messages' do
        listener = SerializationOptimizingListener.new
        unit = Object.new

        event = Domain::DomainEventMessage.build
        decorated = listener.on_event_registered unit, event
        assert decorated.is_a? Serialization::SerializationAwareDomainEventMessage

        event = Domain::EventMessage.build
        decorated = listener.on_event_registered unit, event
        assert decorated.is_a? Serialization::SerializationAwareEventMessage
      end
    end

  end
end
