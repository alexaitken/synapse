module Synapse
  module UnitOfWork
    # Represents a mechanism for notifying registered listeners in a specific order of precendence
    #
    # When #on_start, #on_event_registered, #on_prepare_commit and #on_prepare_transactional_commit
    # are invoked, the listeners will be notified the order they were added to this colleciton.
    # When #after_commit, #on_rollback and #on_cleanup are called, listeners will be notified in
    # the reverse order they were added to this collection
    #
    # This behavior is particularly useful for an auditing listener, which could log a commit
    # before any listeners are allowed to do anything, and log that the commit is finished after
    # all other listeners have finished.
    class UnitOfWorkListenerCollection < UnitOfWorkListener
      def initialize
        @listeners = Array.new
      end

      # Registers a unit of work listener with this collection
      #
      # @param [UnitOfWorkListener] listener
      # @return [undefined]
      def <<(listener)
        @listeners << listener
      end

      # @param [UnitOfWork] uow
      # @return [undefined]
      def on_start(uow)
        @listeners.each do |listener|
          listener.on_start uow
        end
      end

      # @param [UnitOfWork] uow
      # @param [EventMessage] event
      # @return [EventMessage]
      def on_event_registered(uow, event)
        @listeners.each do |listener|
          event = listener.on_event_registered uow, event
        end

        event
      end

      # @param [UnitOfWork] uow
      # @param [Array<AggregateRoot>] aggregates
      # @param [Hash<EventBus, Array>] events
      # @return [undefined]
      def on_prepare_commit(uow, aggregates, events)
        @listeners.each do |listener|
          listener.on_prepare_commit uow, aggregates, events
        end
      end

      # @param [UnitOfWork] uow
      # @param [Object] transaction
      # @return [undefined]
      def on_prepare_transaction_commit(uow, transaction)
        @listeners.each do |listener|
          listener.on_prepare_transaction_commit uow, transaction
        end
      end

      # @param [UnitOfWork] uow
      # @return [undefined]
      def after_commit(uow)
        @listeners.reverse_each do |listener|
          listener.after_commit uow
        end
      end

      # @param [UnitOfWork] uow
      # @param [Error] cause
      # @return [undefined]
      def on_rollback(uow, cause = nil)
        @listeners.reverse_each do |listener|
          listener.on_rollback uow, cause
        end
      end

      # @param [UnitOfWork] uow
      # @return [undefined]
      def on_cleanup(uow)
        @listeners.reverse_each do |listener|
          listener.on_cleanup uow
        end
      end
    end
  end
end
