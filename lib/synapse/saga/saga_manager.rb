module Synapse
  module Saga
    # Represents a mechanism for managing the lifeycle and notification of saga instances
    # @abstract
    class SagaManager
      include EventBus::EventListenerProxy
      include Loggable

      # @return [LockManager]
      attr_reader :lock_manager

      # @return [SagaFactory]
      attr_reader :factory

      # @return [SagaRepository]
      attr_reader :repository

      # @return [Boolean] Returns true if exceptions will be logged silently
      attr_accessor :suppress_exceptions

      # @param [SagaRepository] repository
      # @param [SagaFactory] factory
      # @param [LockManager] lock_manager
      # @param [Class...] saga_types
      # @return [undefined]
      def initialize(repository, factory, lock_manager, *saga_types)
        @repository = repository
        @factory = factory
        @lock_manager = lock_manager
        @saga_types = saga_types.flatten

        @suppress_exceptions = true
      end

      # @param [EventMessage] event
      # @return [undefined]
      def notify(event)
        @saga_types.each do |saga_type|
          correlation = extract_correlation saga_type, event
          if correlation
            current = notify_current_sagas saga_type, event, correlation
            if should_start_new_saga saga_type, event, current
              start_new_saga saga_type, event, correlation
            end
          end
        end
      end

      # @return [Class]
      def proxied_type
        @saga_types.first
      end

      protected

      # @abstract
      # @param [Class] saga_type
      # @param [EventMessage] event
      # @return [Symbol]
      def creation_policy_for(saga_type, event)
        raise NotImplementedError
      end

      # @abstract
      # @param [Class] saga_type
      # @param [EventMessage] event
      # @return [Correlation] Returns nil if no correlation could be extracted
      def extract_correlation(saga_type, event)
        raise NotImplementedError
      end

      private

      # Determines whether or not a new saga should be started, based off of existing sagas
      # and the creation policy for the event and saga
      #
      # @param [Class] saga_type
      # @param [EventMessage] event
      # @param [Boolean] current_sagas True if there are existing sagas
      # @return [Boolean]
      def should_start_new_saga(saga_type, event, current_sagas)
        creation_policy = creation_policy_for saga_type, event

        if :always == creation_policy
          true
        elsif :if_none_found == creation_policy
          !current_sagas
        else
          false
        end
      end

      # Notifies existing sagas of the given type and correlation of the given event
      #
      # @param [Class] saga_type
      # @param [EventMessage] event
      # @param [Correlation] correlation
      # @return [Boolean] Returns true if any current sagas were found and notified
      def notify_current_sagas(saga_type, event, correlation)
        sagas = @repository.find saga_type, correlation

        saga_invoked = false
        sagas.each do |saga_id|
          @lock_manager.obtain_lock saga_id
          begin
            loaded_saga = notify_current_saga saga_id, event, correlation
            if loaded_saga
              saga_invoked = true
            end
          ensure
            @lock_manager.release_lock saga_id
          end
        end

        saga_invoked
      end

      # Loads and notifies the saga with the given identifier of the given event
      #
      # @param [String] saga_id
      # @param [EventMessage] event
      # @param [Correlation] correlation
      # @return [Saga]
      def notify_current_saga(saga_id, event, correlation)
        saga = @repository.load saga_id

        unless saga && saga.active && saga.correlations.include?(correlation)
          # Saga has changed or was deleted between the time of the selection query and the
          # actual loading and locking of the saga
          return
        end

        begin
          notify_saga saga, event
        ensure
          @repository.commit saga
        end

        saga
      end

      # Creates a new saga of the given type with the given correlation
      #
      # After the saga has been created, it is notified of the given event and then is
      # committed to the saga repository.
      #
      # @param [Class] saga_type
      # @param [EventMessage] event
      # @param [Correlation] correlation
      # @return [undefined]
      def start_new_saga(saga_type, event, correlation)
        saga = @factory.create saga_type
        saga.correlations.add correlation

        @lock_manager.obtain_lock saga.id

        begin
          notify_saga saga, event
        ensure
          begin
            @repository.add saga
          ensure
            @lock_manager.release_lock saga.id
          end
        end
      end

      # Notifies the given saga with of the given event
      #
      # @raise [Exception] If an error occurs while notifying the saga and exception
      #   suppression is disabled
      # @param [Saga] saga
      # @param [EventMessage] event
      # @return [undefined]
      def notify_saga(saga, event)
        saga.handle event
      rescue => exception
        raise unless @suppress_exceptions

        backtrace = exception.backtrace.join $RS
        logger.error "Exception occured while invoking saga " +
          "{#{saga.class}} {#{saga.id}} with {#{event.payload_type}}:\n" +
          "#{exception.inspect} #{backtrace}"
      end
    end # SagaManager
  end # Saga
end
