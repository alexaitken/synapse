module Synapse
  module UnitOfWork
    # Mechanism for notifying registered listeners in a specific order of precendence
    #
    # When the following methods are invoked, the listeners will be notified in the order
    # they were registered with the unit of work:
    #
    # + {#on_event_registered}
    # + {#on_prepare_commit}
    # + {#on_prepare_transaction_commit}
    #
    # When the following methods are invoked, the listeners will be notified in the reverse order
    # they were registered with the unit of work:
    #
    # + {#after_commit}
    # + {#on_rollback}
    # + {#on_cleanup}
    #
    # This behavior is particularly useful for an auditing listener, which could log a commit
    # before any listeners are allowed to do anything, and log that the commit is finished after
    # all other listeners have finished.
    class UnitListenerList
      include Loggable

      # @return [undefined]
      def initialize
        @listeners = []
      end

      # Pushes a unit listener onto the end of this list
      #
      # @param [UnitListener] listener
      # @return [undefined]
      def push(listener)
        logger.debug "Registering listener {#{listener.class}}"
        @listeners.push listener
      end

      # @param [Unit] unit
      # @param [EventMessage] event
      # @return [EventMessage]
      def on_event_registered(unit, event)
        @listeners.each do |listener|
          event = listener.on_event_registered unit, event
        end

        event
      end

      # @param [Unit] unit
      # @param [Array] aggregates
      # @param [Array] events
      # @return [undefined]
      def on_prepare_commit(unit, aggregates, events)
        @listeners.each do |listener|
          logger.debug "Notifying {#{listener.class}} that unit is preparing for commit"
          listener.on_prepare_commit unit, aggregates, events
        end
      end

      # @param [Unit] unit
      # @param [Object] transaction
      # @return [undefined]
      def on_prepare_transaction_commit(unit, transaction)
        @listeners.each do |listener|
          logger.debug "Notifying {#{listener.class}} that unit is preparing for transaction commit"
          listener.on_prepare_transaction_commit unit, transaction
        end
      end

      # @param [Unit] unit
      # @return [undefined]
      def after_commit(unit)
        @listeners.reverse_each do |listener|
          logger.debug "Notifying {#{listener.class}} that unit has been committed"
          listener.after_commit unit
        end
      end

      # @param [Unit] unit
      # @param [Exception] cause
      # @return [undefined]
      def on_rollback(unit, cause = nil)
        @listeners.reverse_each do |listener|
          logger.debug "Notifying {#{listener.class}} that unit is rolling back"
          listener.on_rollback unit, cause
        end
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_cleanup(unit)
        @listeners.reverse_each do |listener|
          logger.debug "Notifying {#{listener.class}} that unit is cleaning up"

          begin
            listener.on_cleanup unit
          rescue
            # TODO Log the exception
            logger.warn "Listener {#{listener.class}} raised exception during cleanup"
          end
        end

        logger.debug 'Listeners notified of cleanup'
      end
    end # UnitListenerList
  end # UnitOfWork
end
