module Synapse
  module ProcessManager
    # Simple implementation of a process manager
    class SimpleProcessManager < ProcessManager
      # @return [Array<Class>] Types of events that will always result in the creation of a process
      attr_accessor :always_create_events

      # @return [Array<Class>] Types of events that will result in the creation of a process if one
      #   doesn't already exist
      attr_accessor :optionally_create_events

      # @param [ProcessRepository] repository
      # @param [ProcessFactory] factory
      # @param [LockManager] lock_manager
      # @param [CorrelationResolver] correlation_resolver
      # @param [Class...] process_types
      # @return [undefined]
      def initialize(repository, factory, lock_manager, correlation_resolver, *process_types)
        super repository, factory, lock_manager, *process_types

        @correlation_resolver = correlation_resolver
        @always_create_events = Array.new
        @optionally_create_events = Array.new
      end

      protected

      # @param [Class] process_type
      # @param [EventMessage] event
      # @return [Symbol]
      def creation_policy_for(process_type, event)
        if @always_create_events.include? event.payload_type
          :always
        elsif @optionally_create_events.include? event.payload_type
          :if_none_found
        else
          :none
        end
      end

      # @param [Class] process_type
      # @param [EventMessage] event
      # @return [Correlation] Returns nil if no correlation could be extracted
      def extract_correlation(process_type, event)
        @correlation_resolver.resolve event
      end
    end # SimpleProcessManager
  end # ProcessManager
end
