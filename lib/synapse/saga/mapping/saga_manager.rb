module Synapse
  module Saga
    # Saga manager that is aware of sagas that use the mapping DSL
    # @see MappingSaga
    class MappingSagaManager < SagaManager
      # @raise [ArgumentError] If a saga type is given that doesn't support the mapping DSL
      # @param [SagaRepository] repository
      # @param [SagaFactory] factory
      # @param [LockManager] lock_manager
      # @param [Class...] saga_types
      # @return [undefined]
      def initialize(repository, factory, lock_manager, *saga_types)
        super

        @saga_types.each do |saga_type|
          unless saga_type.respond_to? :event_mapper
            raise ArgumentError, "Incompatible saga type #{saga_type}"
          end
        end
      end

      protected

      # @param [Class] saga_type
      # @param [EventMessage] event
      # @return [Symbol]
      def creation_policy_for(saga_type, event)
        mapping = saga_type.event_mapper.mapping_for event.payload_type

        if mapping
          if !mapping.options[:start]
            :none
          elsif mapping.options[:force_new]
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
        mapping = saga_type.event_mapper.mapping_for event.payload_type
        # Saga does not have a mapping for this event
        return unless mapping

        key = mapping.options[:correlate]
        # Mapping does not contain a correlation key
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
    end # MappingSagaManager
  end # Saga
end
