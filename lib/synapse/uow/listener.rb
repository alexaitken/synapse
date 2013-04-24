module Synapse
  module UnitOfWork
    # Listener that is registered to a unit of work and is notified of state changes
    # @abstract
    class UnitOfWorkListener
      # Invoked when the unit of work has been started
      #
      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_start(unit); end

      # Invoked when an event is registered for publication when the unit of work is committed
      #
      # Listeners may alter event information. Note that the listener must ensure the functional
      # meaning of the message does not change. Typically, this is done only by modifying the
      # metadata of the message.
      #
      # @param [UnitOfWork] unit
      # @param [EventMessage] event
      # @return [EventMessage]
      def on_event_registered(unit, event)
        event
      end

      # Invoked before aggregates are committed, and before any events are published
      #
      # This phase can be used to do validation or any other activity that should be able to
      # prevent event publication in certain circumstances.
      #
      # @param [UnitOfWork] unit
      # @param [Array<AggregateRoot>] aggregates
      # @param [Hash<EventBus, Array>] events
      # @return [undefined]
      def on_prepare_commit(unit, aggregates, events); end

      # Invoked before the transaction bound to this unit of work is committed, but after all
      # other commit activities (publication of events and storage of aggregates) are performed
      #
      # This gives a resource manager the opportunity to take actions that must be part of the
      # same transaction. Note that this method is only invoked if the unit of work is bound
      # to a transaction.
      #
      # @param [UnitOfWork] unit
      # @param [Object] transaction
      # @return [undefined]
      def on_prepare_transaction_commit(unit, transaction); end

      # Invoked when the unit of work is committed
      #
      # At this point, any registered aggregates have been stored and any registered events have
      # been scheduled for publication. When processing of this method causes an exception, the
      # unit of work may choose to rollback.
      #
      # @param [UnitOfWork] unit
      # @return [undefined]
      def after_commit(unit); end

      # Invoked when the unit of work is rolled back
      #
      # Alternatively, the unit of work may choose to invoke this method when the commit of the
      # unit of work failed as well.
      #
      # @param [UnitOfWork] unit
      # @param [Error] cause
      # @return [undefined]
      def on_rollback(unit, cause = nil); end

      # Invoked while a unit of work is being cleaned up
      #
      # This gives listeners the opportunity to release resources that might have been acquired
      # during commit or rollback operations, such as locks. This method is always called after all
      # listeners have been notified of a commit or rollback operation.
      #
      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_cleanup(unit); end
    end
  end
end
