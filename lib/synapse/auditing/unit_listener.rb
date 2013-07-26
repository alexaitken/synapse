module Synapse
  module Auditing
    # Unit of work listener that audits the outcome of a command dispatch
    # @api private
    class AuditingUnitOfWorkListener < UnitOfWork::UnitOfWorkListener
      # @return [Array<EventMessage>]
      attr_reader :recorded_events

      # @return [Object]
      attr_accessor :return_value

      # @param [CommandMessage] command
      # @param [Array<AuditDataProvider>] data_providers
      # @param [Array<AuditLogger>] loggers
      # @return [undefined]
      def initialize(command, data_providers, loggers)
        @command = command
        @data_providers = data_providers
        @loggers = loggers
        @recorded_events = Array.new
      end

      # @param [UnitOfWork] unit
      # @param [EventMessage] event
      # @return [EventMessage]
      def on_event_registered(unit, event)
        audit_data = Hash.new
        @data_providers.each do |provider|
          audit_data.merge! provider.provide_data_for @command
        end

        event = event.and_metadata audit_data
        @recorded_events.push event

        event
      end

      # @param [UnitOfWork] unit
      # @return [undefined]
      def after_commit(unit)
        @loggers.each do |logger|
          logger.on_success @command, @return_value, @recorded_events
        end
      end

      # @param [UnitOfWork] unit
      # @param [Error] cause
      # @return [undefined]
      def on_rollback(unit, cause = nil)
        @loggers.each do |logger|
          logger.on_failure @command, cause, @recorded_events
        end
      end
    end # AuditingUnitOfWorkListener
  end # Auditing
end
