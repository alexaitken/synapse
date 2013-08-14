module Synapse
  module Saga
    # Saga manager that is aware of sagas that use the message routing DSL
    # @see RoutedSaga
    class RoutedSagaManager < SagaManager
      # @raise [ArgumentError] If a saga type is given that doesn't support the routing DSL
      # @param [SagaRepository] repository
      # @param [SagaFactory] factory
      # @param [LockManager] lock_manager
      # @param [Class...] saga_types
      # @return [undefined]
      def initialize(repository, factory, lock_manager, *saga_types)
        super

        @saga_types.each do |saga_type|
          unless saga_type.respond_to? :event_router
            raise ArgumentError, "Incompatible saga type #{saga_type}"
          end
        end
      end

      protected

      # @param [Class] saga_type
      # @param [EventMessage] event
      # @return [Symbol]
      def creation_policy_for(saga_type, event)
        handler = saga_type.event_router.handler_for event

        if handler
          if !handler.options[:start]
            :none
          elsif handler.options[:force_new]
            :always
          else
            :if_none_found
          end
        end
      end

      # @param [Class] saga_type
      # @param [EventMessage] event
      # @return [Correlation] Returns nil if no correlation could be extracted
      def extract_correlation(saga_type, event)
        handler = saga_type.event_router.handler_for event
        # Saga does not have a handler for this event
        return unless handler

        key = handler.options[:correlate]
        # Handler does not contain a correlation key
        return unless key

        payload = event.payload
        unless payload.respond_to? key
          raise "Correlation key {#{key}} not valid for event #{payload.class}"
        end

        value = payload.public_send key
        # The value of the correlation key for the event is nil
        return unless value

        Correlation.new key, value
      end
    end # RoutedSagaManager
  end # Saga
end
