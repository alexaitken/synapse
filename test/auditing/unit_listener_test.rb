require 'test_helper'

module Synapse
  module Auditing

    class AuditingUnitOfWorkListenerTest < Test::Unit::TestCase
      def test_on_event_registered
        data_provider_a = Object.new
        data_provider_b = Object.new

        command = Object.new
        data_providers = [data_provider_a, data_provider_b]
        loggers = []

        listener = AuditingUnitOfWorkListener.new command, data_providers, loggers

        event = Object.new

        data_a = { foo: 0 }
        data_b = { bar: 1 }

        mock(data_provider_a).provide_data_for(command) { data_a }
        mock(data_provider_b).provide_data_for(command) { data_b }

        mock(event).and_metadata(data_a.merge(data_b)) { event }

        out = listener.on_event_registered(Object.new, event)

        assert_same event, out
        assert listener.recorded_events.include? event
      end

      def test_after_commit
        logger = Object.new

        command = Object.new
        return_value = Object.new
        data_providers = []
        loggers = [logger]
        event = Object.new

        mock(logger).on_success(command, return_value, [event])

        listener = AuditingUnitOfWorkListener.new command, data_providers, loggers
        listener.return_value = return_value
        listener.recorded_events.push event

        listener.after_commit Object.new
      end

      def test_on_rollback
        logger = Object.new

        command = Object.new
        exception = Exception.new
        data_providers = []
        loggers = [logger]
        event = Object.new

        mock(logger).on_success(command, exception, [event])

        listener = AuditingUnitOfWorkListener.new command, data_providers, loggers
        listener.recorded_events.push event

        listener.on_rollback Object.new, exception
      end
    end

  end
end
