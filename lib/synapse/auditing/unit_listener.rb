module Synapse
  module Auditing
    # Unit of work listener that audits the outcome of a command dispatch
    # @api private
    class AuditingUnitOfWorkListener < UnitOfWork::UnitOfWorkListener
      # @return [Array]
      attr_reader :recorded_events

      # @return [Object]
      attr_accessor :return_value

      # @param [CommandMessage] command
      # @param [DataProvider] data_provider
      # @param [AuditLogger] logger
      # @return [undefined]
      def initialize(command, data_provider, logger)
        @command = command
        @data_provider = data_provider
        @logger = logger
        @recorded_events = Array.new
      end

      # @param [UnitOfWork] unit
      # @param [EventMessage] event
      # @return [EventMessage]
      def on_event_registered(unit, event)
        audit_data = @data_provider.provide_data_for @command
        unless audit_data.empty?
          event = event.and_metadata audit_data
        end

        @recorded_events.push event

        event
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def after_commit(unit)
        @logger.on_success @command, @return_value, @recorded_events
      end

      # @param [UnitOfWork] unit
      # @param [Error] cause
      # @return [undefined]
      def on_rollback(unit, cause = nil)
        @logger.on_failure @command, cause, @recorded_events
      end
    end # AuditingUnitOfWorkListener
  end # Auditing
end
