module Synapse
  module UnitOfWork
    # Implementation of a unit of work that defers the publication of events and persistence of
    # aggregates until the unit of work is explicitly committed.
    class DefaultUnit < NestableUnit
      # Creates and starts a unit of work with the given transaction manager
      #
      # @param [TransactionManager] transaction_manager
      # @return [DefaultUnit]
      def self.start(transaction_manager = nil)
        unit = new(transaction_manager)
        unit.start

        unit
      end

      # @param [TransactionManager] transaction_manager
      # @return [undefined]
      def initialize(transaction_manager = nil)
        super()

        @transaction_manager = transaction_manager

        @registered_aggregates = {}
        @deferred_events = Hash.new do |hash, k|
          hash[k] = []
        end
        @listeners = UnitListenerList.new
      end

      # @yield [AggregateRoot]
      # @param [AggregateRoot] aggregate
      # @param [EventBus] event_bus
      # @return [AggregateRoot] The aggregate being tracked by this unit of work
      def register_aggregate(aggregate, event_bus, &block)
        similar_aggregate = find_similar_aggregate(aggregate.class, aggregate.id)
        if similar_aggregate
          logger.info "Ignoring aggregate registration, similar aggregate already registered: " +
            "{#{aggregate.class}} {#{aggregate.id}}"

          return similar_aggregate
        end

        @registered_aggregates[aggregate] = block

        aggregate.add_registration_listener do |event|
          event = notify_event_registered(event)
          defer_publication(event, event_bus)
          event
        end

        aggregate
      end

      # @param [EventMessage] event
      # @param [EventBus] event_bus
      # @return [undefined]
      def publish_event(event, event_bus)
        logger.debug "Staging event {#{event.class}} for publication on {#{event_bus.class}}"

        event = notify_event_registered(event)
        defer_publication(event, event_bus)
      end

      # @param [UnitListener] listener
      # @return [undefined]
      def register_listener(listener)
        @listeners.push(listener)
      end

      # @return [Boolean]
      def transactional?
        !!@transaction_manager
      end

      protected

      # @return [undefined]
      def store_aggregates
        logger.debug "Persisting changes to aggregates"

        @registered_aggregates.each_pair do |aggregate, block|
          logger.debug "Persisting changes to {#{aggregate.class}} {#{aggregate.id}}"
          block.call aggregate
        end

        logger.debug "Changes to aggregates persisted"
        @registered_aggregates.clear
      end

      # @return [undefined]
      def perform_start
        if transactional?
          @transaction = @transaction_manager.start
        end
      end

      # @return [undefined]
      def perform_commit
        publish_events
        commit_inner_units

        if transactional?
          notify_prepare_transaction_commit
          @transaction_manager.commit(@transaction)
        end

        notify_after_commit
      end

      # @param [Exception] cause
      # @return [undefined]
      def perform_rollback(cause)
        rollback_inner_units(cause)

        @registered_aggregates.clear
        @deferred_events.clear

        begin
          if @transaction
            @transaction_manager.rollback(@transaction)
          end
        ensure
          notify_rollback cause
        end
      end

      # @!group Notification aliases

      # @param [EventMessage] event
      # @return [EventMessage]
      def notify_event_registered(event)
        @listeners.on_event_registered(self, event)
      end

      # @return [undefined]
      def notify_prepare_commit
        aggregates = @registered_aggregates.keys
        events = @deferred_events.values.flatten

        @listeners.on_prepare_commit(self, aggregates, events)
      end

      # @return [undefined]
      def notify_prepare_transaction_commit
        @listeners.on_prepare_transaction_commit(self, @transaction)
      end

      # @return [undefined]
      def notify_after_commit
        @listeners.after_commit(self)
      end

      # @param [Exception] cause
      # @return [undefined]
      def notify_rollback(cause)
        @listeners.on_rollback(self, cause)
      end

      # @return [undefined]
      def notify_cleanup
        @listeners.on_cleanup(self)
      end

      #!endgroup

      private

      # @param [EventMessage] event
      # @param [EventBus] event_bus
      # @return [undefined]
      def defer_publication(event, event_bus)
        @deferred_events.get(event_bus).push(event)
      end

      # @return [undefined]
      def publish_events
        logger.debug "Publishing events to the event bus"

        @publishing = true
        until @deferred_events.empty?
          @deferred_events.keys.each do |event_bus|
            logger.debug "Publishing deferred events to {#{event_bus.class}}"
            events = @deferred_events.delete(event_bus)
            event_bus.publish(*events)
          end
        end

        logger.debug "Deferred events have been published"
      end

      # @param [Class] aggregate_type
      # @param [Object] aggregate_id
      # @return [AggregateRoot]
      def find_similar_aggregate(aggregate_type, aggregate_id)
        @registered_aggregates.each_key do |candidate|
          if candidate.id == aggregate_id && candidate.is_a?(aggregate_type)
            return candidate
          end
        end

        nil
      end
    end # DefaultUnit
  end # UnitOfWork
end
