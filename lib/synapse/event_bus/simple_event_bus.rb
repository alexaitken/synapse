module Synapse
  module EventBus
    # Implementation of an event bus that notifies any subscribed event listeners in the calling
    # thread. Listeners are expected to implement asynchronous handing themselves, if desired.
    class SimpleEventBus < EventBus
      def initialize
        @listeners = Set.new
        @logger = Logging.logger[self.class]
      end

      # @param [EventMessage...] events
      # @return [undefined]
      def publish(*events)
        if @listeners.empty?
          return
        end

        events.flatten!
        events.each do |event|
          @listeners.each do |listener|
            if @logger.debug?
              listener_type = actual_type listener
              @logger.debug 'Dispatching event [%s] to listener [%s]' %
                [event.payload_type, listener_type]
            end

            listener.notify event
          end
        end
      end

      # @param [EventListener] listener
      # @return [undefined]
      def subscribe(listener)
        listener_type = actual_type listener

        if @listeners.add? listener
          @logger.debug 'Event listener [%s] subscribed' % listener_type
        else
          @logger.info 'Event listener [%s] not added, was already subscribed' % listener_type
        end
      end

      # @param [EventListener] listener
      # @return [undefined]
      def unsubscribe(listener)
        listener_type = actual_type listener

        if @listeners.delete? listener
          @logger.debug 'Event listener [%s] unsubscribed' % listener_type
        else
          @logger.info 'Event listener [%s] not removed, was not subscribed' % listener_type
        end
      end

    private

      # @param [EventListener] listener
      # @return [Class]
      def actual_type(listener)
        if listener.respond_to? :proxied_type
          listener.proxied_type
        else
          listener.class
        end
      end
    end
  end
end
