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
      end

      # Registers a unit of work listener with this collection
      #
      # @param [UnitOfWorkListener] listener
      # @return [undefined]
      def <<(listener)
        @listeners << listener
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_start(unit)
        @listeners.each do |listener|
          listener.on_start unit
        end
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
        @listeners.each do |listener|
          listener.on_prepare_commit unit, aggregates, events
        end
      end

      # @param [UnitOfWork] unit
      # @param [Object] transaction
      # @return [undefined]
      def on_prepare_transaction_commit(unit, transaction)
        @listeners.each do |listener|
          listener.on_prepare_transaction_commit unit, transaction
        end
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def after_commit(unit)
        @listeners.reverse_each do |listener|
          listener.after_commit unit
        end
      end

      # @param [UnitOfWork] unit
      # @param [Error] cause
      # @return [undefined]
      def on_rollback(unit, cause = nil)
        @listeners.reverse_each do |listener|
          listener.on_rollback unit, cause
        end
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def on_cleanup(unit)
        @listeners.reverse_each do |listener|
          listener.on_cleanup unit
        end
      end
    end
  end
end
