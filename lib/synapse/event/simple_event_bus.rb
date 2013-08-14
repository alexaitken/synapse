module Synapse
  module Event
    # Implementation of an event bus that notifies any subscribed event listeners in the calling
    # thread. Listeners are expected to implement asynchronous handing themselves, if desired.
    class SimpleEventBus < EventBus
      include EventListenerProxyAware
      include Loggable

      # @return [undefined]
      def initialize
        @listeners = Contender::CopyOnWriteSet.new
      end

      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        return if @listeners.empty?

        events.flatten!
        events.each do |event|
          @listeners.each do |listener|
            if logger.debug?
              listener_type = resolve_listener_type listener
              logger.debug "Publishing event {#{event.payload_type}} to {#{listener_type}}"
            end

            listener.notify event
          end
        end
      end

      # Returns true if the given listener is subscribed to this event bus
      #
      # @param [EventListener] listener
      # @return [Boolean]
      def subscribed?(listener)
        @listeners.include? listener
      end

      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        listener_type = resolve_listener_type listener

        if @listeners.add? listener
          logger.debug "Event listener {#{listener_type}} subscribed"
        else
          logger.info "Event listener {#{listener_type}} is already subscribed"
        end
      end

      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        listener_type = resolve_listener_type listener

        if @listeners.delete? listener
          logger.debug "Event listener {#{listener_type}} unsubscribed"
        else
          logger.info "Event listener {#{listener_type}} is not subscribed"
        end
      end
    end # SimpleEventBus
  end # EventBus
end
