module Synapse
  module Saga
    # Simple implementation of a saga manager
    class SimpleSagaManager < SagaManager
      # @return [Set] Types of events that will always result in the creation of a saga
      attr_writer :always_create_events

      # @return [Set] Types of events that will result in the creation of a saga if one
      #   doesn't already exist
      attr_writer :optionally_create_events

      # @param [SagaRepository] repository
      # @param [SagaFactory] factory
      # @param [LockManager] lock_manager
      # @param [CorrelationResolver] correlation_resolver
      # @param [Class...] saga_types
      # @return [undefined]
      def initialize(repository, factory, lock_manager, correlation_resolver, *saga_types)
        super repository, factory, lock_manager, *saga_types

        @correlation_resolver = correlation_resolver
        @always_create_events = Set.new
        @optionally_create_events = Set.new
      end

      protected

      # @param [Class] saga_type
      # @param [EventMessage] event
      # @return [Symbol]
      def creation_policy_for(saga_type, event)
        if @always_create_events.include? event.payload_type
          :always
        elsif @optionally_create_events.include? event.payload_type
          :if_none_found
        else
          :none
        end
      end

      # @param [Class] saga_type
      # @param [EventMessage] event
      # @return [Correlation] Returns nil if no correlation could be extracted
      def extract_correlation(saga_type, event)
        @correlation_resolver.resolve event
      end
    end # SimpleSagaManager
  end # Saga
end
