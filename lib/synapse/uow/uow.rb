module Synapse
  module UnitOfWork
    # Default implementation of a unit of work
    class UnitOfWork < NestableUnitOfWork
      # @param [UnitOfWorkProvider] provider
      # @return [undefined]
      def initialize(provider)
        super

        @aggregates = Hash.new
        @events = Hash.new do |hash, key|
          hash.put key, Array.new
        end
        @listeners = UnitOfWorkListenerCollection.new
      end

      # Returns true if this unit of work is bound to a transaction
      #
      # @api public
      # @return [Boolean]
      def transactional?
        !!@transaction_manager
      end

      # Registers a listener that is notified of state changes in this unit of work
      #
      # @api public
      # @param [UnitOfWorkListener] listener
      # @return [undefined]
      def register_listener(listener)
        @listeners.push listener
      end

      # Registers an aggregate with this unit of work
      #
      # This unit of work adds an event listener to the aggregate so that any events generated
      # are published to the given event bus when this unit of work is committed.
      #
      # The provided storage callback is used to commit the aggregate to its respective
      # underlying storage mechanism.
      #
      # If there is already an aggregate registered with this unit of work of the same type
      # and with the same identifier, that aggregate will be returned instead of the given
      # aggregate.
      #
      # @api public
      # @yield [AggregateRoot] Deferred until the aggregate is stored
      # @param [AggregateRoot] aggregate
      # @param [EventBus] event_bus
      # @param [Proc] storage_callback
      # @return [AggregateRoot]
      def register_aggregate(aggregate, event_bus, &storage_callback)
        similar = find_similar_aggregate aggregate
        return similar if similar

        aggregate.add_registration_listener do |event|
          publish_event event, event_bus
        end

        @aggregates.put aggregate, storage_callback

        aggregate
      end

      # Buffers an event for publication to the given event bus until this unit of work is
      # committed
      #
      # @api public
      # @param [EventMessage] event
      # @param [EventBus] event_bus
      # @return [EventMessage] The event that will be published to the event bus
      def publish_event(event, event_bus)
        event = @listeners.on_event_registered self, event

        events = @events.get event_bus
        events.push event

        event
      end

      # Sets the transaction manager that will be used by this unit of work
      #
      # @api public
      # @raise [RuntimeError] If unit of work has been started
      # @param [TransactionManager] transaction_manager
      # @return [undefined]
      def transaction_manager=(transaction_manager)
        if started?
          raise 'Transaction manager not permitted to change after unit of work has started'
        end

        @transaction_manager = transaction_manager
      end

      protected

      # @return [undefined]
      def perform_commit
        publish_events
        commit_inner_units

        if transactional?
          @listeners.on_prepare_transaction_commit self, @transaction
          @transaction_manager.commit @transaction
        end

        @listeners.after_commit self
      end

      # @param [Error] cause
      # @return [undefined]
      def perform_rollback(cause = nil)
        @aggregates.clear
        @events.clear

        begin
          if @transaction
            @transaction_manager.rollback @transaction
          end
        ensure
          @listeners.on_rollback self, cause
        end
      end

      # @return [undefined]
      def notify_cleanup
        @listeners.on_cleanup self
      end

      # @return [undefined]
      def notify_prepare_commit
        @listeners.on_prepare_commit self, @aggregates.keys, @events
      end

      # @return [undefined]
      def perform_start
        if transactional?
          @transaction = @transaction_manager.start
        end

        @listeners.on_start self
      end

      # @return [undefined]
      def store_aggregates
        @aggregates.each_pair do |aggregate, storage_callback|
          storage_callback.call aggregate
        end

        @aggregates.clear
      end

      private

      # Checks if an aggregate of the same type and identifier as the given aggregate has been
      # previously registered with this unit work. If one is found, it is returned.
      #
      # @param [AggregateRoot] aggregate
      # @return [AggregateRoot] Returns nil if no similar aggregate was found
      def find_similar_aggregate(aggregate)
        @aggregates.each_key do |candidate|
          if aggregate.id == candidate.id && candidate.is_a?(candidate.class)
            return candidate
          end
        end

        nil
      end

      # Continually publishes all buffered events to their respective event buses until all
      # events have been published
      def publish_events
        until @events.empty?
          @events.keys.each do |event_bus|
            events = @events.delete event_bus
            event_bus.publish events
          end
        end
      end
    end # UnitOfWork
  end # UnitOfWork
end
