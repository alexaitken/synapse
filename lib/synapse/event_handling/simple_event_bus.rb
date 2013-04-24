module Synapse
  module EventHandling
    # Implementation of an event bus that notifies any subscribed event listeners in the calling
    # thread. Listeners are expected to implement asynchronous handing themselves, if desired.
    class SimpleEventBus < EventBus
      def initialize
        @listeners = Set.new
      end

      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        if @listeners.empty?
          return
        end

        events.flatten!
        events.each do |e|
          @listeners.each do |l|
            l.notify e
          end
        end
      end

      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        @listeners.add listener
      end

      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        @listeners.delete listener
      end
    end
  end
end
