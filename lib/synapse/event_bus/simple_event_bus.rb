module Synapse
  module EventBus
    # Implementation of an event bus that notifies any subscribed event listeners in the calling
    # thread. Listeners are expected to implement asynchronous handing themselves, if desired.
    class SimpleEventBus < EventBus
      def initialize
        @listeners = Set.new
        @logger = Logging.logger[self.class]
      end

      # @api public
      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        if @listeners.empty?
          return
        end

        events.flatten!
        events.each do |event|
          @listeners.each do |listener|
            @logger.debug 'Dispatching event [%s] to listener [%s]' %
              [event.payload_type, listener.class]

            listener.notify event
          end
        end
      end

      # @api public
      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        if @listeners.add? listener
          @logger.debug 'Event listener [%s] subscribed' % listener.class
        else
          @logger.info 'Event listener [%s] not added, was already subscribed' % listener.class
        end
      end

      # @api public
      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        if @listeners.delete? listener
          @logger.debug 'Event listener [%s] unsubscribed' % listener.class
        else
          @logger.info 'Event listener [%s] not removed, was not subscribed' % listener.class
        end
      end
    end
  end
end
