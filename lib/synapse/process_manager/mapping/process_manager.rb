module Synapse
  module ProcessManager
    # Process manager that is aware of processes that use the mapping DSL
    # @see MappingProcess
    class MappingProcessManager < ProcessManager
      # @raise [ArgumentError] If a process type is given that doesn't support the mapping DSL
      # @param [ProcessRepository] repository
      # @param [ProcessFactory] factory
      # @param [LockManager] lock_manager
      # @param [Class...] process_types
      # @return [undefined]
      def initialize(repository, factory, lock_manager, *process_types)
        super

        @process_types.each do |process_type|
          unless process_type.respond_to? :event_mapper
            raise ArgumentError, "Incompatible process type #{process_type}"
          end
        end
      end

      protected

      # @param [Class] process_type
      # @param [EventMessage] event
      # @return [Symbol]
      def creation_policy_for(process_type, event)
        mapping = process_type.event_mapper.mapping_for event.payload_type

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

      # @param [Class] process_type
      # @param [EventMessage] event
      # @return [Correlation] Returns nil if no correlation could be extracted
      def extract_correlation(process_type, event)
        mapping = process_type.event_mapper.mapping_for event.payload_type
        # Process does not have a mapping for this event
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
    end # MappingProcessManager
  end # ProcessManager
end
