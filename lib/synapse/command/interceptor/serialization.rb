module Synapse
  module Command
    # Interceptor that registers a unit of work listener that wraps each event message in a
    # serialization-aware message. This provides optimization in cases where storage (in an event
    # store) and publication (on the event bus) use the same serialization mechansim.
    class SerializationOptimizingInterceptor
      include DispatchInterceptor

      # @return [undefined]
      def initialize
        @listener = SerializationOptimizingUnitListener.new
      end

      # @param [CommandMessage] command
      # @param [Unit] unit
      # @param [InterceptorChain] chain
      # @return [Object] The result of the execution of the command
      def intercept(command, unit, chain)
        unit.register_listener @listener
        chain.proceed command
      end
    end # SerializationOptimizingInterceptor

    # @api private
    class SerializationOptimizingUnitListener
      include  UnitOfWork::UnitListener

      # @param [UnitOfWork] unit
      # @param [EventMessage] event
      # @return [EventMessage]
      def on_event_registered(unit, event)
        if event.is_a? Domain::DomainEventMessage
          Serialization::SerializationAwareDomainEventMessage.decorate event
        else
          Serialization::SerializationAwareEventMessage.decorate event
        end
      end
    end # SerializationOptimizingUnitListener
  end # Command
end
