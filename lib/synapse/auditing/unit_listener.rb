module Synapse
  module Auditing
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
        @data_providers.each do |data_provider|
          audit_data.merge! data_provider.provide_data_for @command
        end

        event.and_metadata(audit_data).tap do
          @recorded_events.push event
        end
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
          logger.on_success @command, cause, @recorded_events
        end
      end
    end
  end
end
