module Synapse
  module UnitOfWork
    # Represents a mechanism for notifying registered listeners in a specific order of precendence
    #
    # When {#on_start}, {#on_event_registered}, {#on_prepare_commit} and
    # {#on_prepare_transaction_commit} are invoked, the listeners will be notified the order
    # they were added to this colleciton. When {#after_commit}, {#on_rollback} and {#on_cleanup}
    # are called, listeners will be notified in the reverse order they were added to this
    # collection.
    #
    # This behavior is particularly useful for an auditing listener, which could log a commit
    # before any listeners are allowed to do anything, and log that the commit is finished after
    # all other listeners have finished.
    class UnitOfWorkListenerCollection < UnitOfWorkListener
      def initialize
        @listeners = Array.new
        @logger = Logging.logger.new self.class
      end

      # Pushes a unit of work listener onto the end of this collection
      #
      # @param [UnitOfWorkListener] listener
      # @return [undefined]
      def push(listener)
        if @logger.debug?
          @logger.debug 'Registering listener [%s]' % listener.class
        end

        @listeners.push listener
      end

      alias << push

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_start(unit)
        @logger.debug 'Notifying listeners that unit of work is starting'

        @listeners.each do |listener|
          if @logger.debug?
            @logger.debug 'Notifying [%s] of start' % listener.class
          end

          listener.on_start unit
        end

        @logger.debug 'Listeners successfully notified'
      end

      # @param [UnitOfWork] unit
      # @param [EventMessage] event
      # @return [EventMessage]
      def on_event_registered(unit, event)
        @listeners.each do |listener|
          event = listener.on_event_registered unit, event
        end

        event
      end

      # @param [UnitOfWork] unit
      # @param [Array<AggregateRoot>] aggregates
      # @param [Hash<EventBus, Array>] events
      # @return [undefined]
      def on_prepare_commit(unit, aggregates, events)
        @logger.debug 'Notifying listeners that commit was requested'

        @listeners.each do |listener|
          if @logger.debug?
            @logger.debug 'Notifying [%s] of commit' % listener.class
          end

          listener.on_prepare_commit unit, aggregates, events
        end

        @logger.debug 'Listeners successfully notified'
      end

      # @param [UnitOfWork] unit
      # @param [Object] transaction
      # @return [undefined]
      def on_prepare_transaction_commit(unit, transaction)
        @logger.debug 'Notifying listeners that transactional commit was requested'

        @listeners.each do |listener|
          if @logger.debug?
            @logger.debug 'Notifying [%s] of transactional commit' % listener.class
          end

          listener.on_prepare_transaction_commit unit, transaction
        end

        @logger.debug 'Listeners successfully notified'
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def after_commit(unit)
        @logger.debug 'Notifying listeners that commit has finished'

        @listeners.reverse_each do |listener|
          if @logger.debug?
            @logger.debug 'Notifying [%s] of finished commit' % listener.class
          end

          listener.after_commit unit
        end

        @logger.debug 'Listeners successfully notified'
      end

      # @param [UnitOfWork] unit
      # @param [Error] cause
      # @return [undefined]
      def on_rollback(unit, cause = nil)
        @logger.debug 'Notifying listeners of rollback'

        @listeners.reverse_each do |listener|
          if @logger.debug?
            @logger.debug 'Notifying [%s] of rollback' % listener.class
          end

          listener.on_rollback unit, cause
        end

        @logger.debug 'Listeners successfully notified'
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_cleanup(unit)
        @logger.debug 'Notifying listeners of cleanup'

        @listeners.reverse_each do |listener|
          if @logger.debug?
            @logger.debug 'Notifying [%s] of cleanup' % listener.class
          end

          begin
            listener.on_cleanup unit
          rescue => exception
            # Ignore this exception so that we can continue cleaning up
            @logger.warn 'Listener raised an exception during cleanup: %s' % exception.inspect
          end
        end

        @logger.debug 'Listeners successfully notified'
      end
    end
  end
end
