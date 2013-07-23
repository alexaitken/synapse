module Synapse
  module EventBus
    # Implementation of an event bus that notifies any subscribed event listeners in the calling
    # thread. Listeners are expected to implement asynchronous handing themselves, if desired.
    class SimpleEventBus < EventBus
      include Loggable

      # @return [undefined]
      def initialize
        @listeners = Set.new
      end

      # @api public
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        return if @listeners.empty?

        events.flatten!
        events.each do |event|
          @listeners.each do |listener|
            logger.debug "Publishing event {#{event.payload_type}} to {#{listener.class}}"

            listener.notify event
          end
        end
      end

      # Returns true if the given listener is subscribed to this event bus
      #
      # @api public
      # @param [EventListener] listener
      # @return [Boolean]
      def subscribed?(listener)
        @listeners.include? listener
      end

      # @api public
      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        if @listeners.add? listener
          logger.debug "Event listener {#{listener.class}} subscribed"
        else
          logger.info "Event listener {#{listener.class}} is already subscribed"
        end
      end

      # @api public
      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        if @listeners.delete? listener
          logger.debug "Event listener {#{listener.class}} unsubscribed"
        else
          logger.info "Event listener {#{listener.class}} is not subscribed"
        end
      end
    end # SimpleEventBus
  end # EventBus
end
