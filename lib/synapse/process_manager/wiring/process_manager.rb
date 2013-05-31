module Synapse
  module ProcessManager
    # Process manager that is aware of processes that use the wiring DSL
    # @see WiringProcess
    class WiringProcessManager < ProcessManager
      # @raise [ArgumentError] If a process type is given that doesn't support the wiring DSL
      # @param [ProcessRepository] repository
      # @param [ProcessFactory] factory
      # @param [LockManager] lock_manager
      # @param [Class...] process_types
      # @return [undefined]
      def initialize(repository, factory, lock_manager, *process_types)
        super

        @process_types.each do |process_type|
          unless process_type.respond_to? :wire_registry
            raise ArgumentError, 'Incompatible process type %s' % process_type
          end
        end
      end

    protected

      # @param [Class] process_type
      # @param [EventMessage] event
      # @return [Symbol]
      def creation_policy_for(process_type, event)
        wire = process_type.wire_registry.wire_for event.payload_type

        if wire
          if !wire.options[:start]
            :none
          elsif wire.options[:force_new]
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
        wire = process_type.wire_registry.wire_for event.payload_type

        return unless wire

        correlation_key = wire.options[:correlate]
        if correlation_key
          correlation_value event.payload, correlation_key
        end
      end

    private

      # @param [Object] payload
      # @param [Symbol] correlation_key
      # @return [Correlation] Returns nil if correlation value could not be extracted
      def correlation_value(payload, correlation_key)
        unless payload.respond_to? correlation_key
          raise 'Correlation key [%s] is not valid for [%s]' % [correlation_key, payload.class]
        end

        value = payload.public_send correlation_key
        if value
          Correlation.new correlation_key, value
        end
      end
    end # WiringProcessManager
  end # ProcessManager
end
