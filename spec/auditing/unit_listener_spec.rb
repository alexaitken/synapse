require 'spec_helper'

module Synapse
  module Auditing

    describe AuditingUnitListener do
      it 'supplements events with auditing data' do
        command = Command::CommandMessage.build do |builder|
          builder.metadata = Hash[:foo, 0]
        end

        event = Event::EventMessage.build do |builder|
          builder.metadata = Hash[:bar, 1]
        end

        listener = AuditingUnitListener.new command, CommandMetadataProvider.new, NullAuditLogger.new

        merged_event = listener.on_event_registered Object.new, event
        merged_event.metadata.should == Hash[:foo, 0, :bar, 1]

        listener.recorded_events.should include merged_event
      end

      it 'notifies the audit logger of success after the unit of work is committed' do
        logger = Object.new

        command = Object.new
        return_value = Object.new
        event = Object.new

        mock(logger).on_success(command, return_value, [event])

        listener = AuditingUnitListener.new command, EmptyDataProvider.new, logger
        listener.return_value = return_value
        listener.recorded_events.push event

        listener.after_commit Object.new
      end

      it 'notifies the audit logger of failure when a unit of work is rolled back' do
        logger = Object.new

        command = Object.new
        exception = Exception.new
        event = Object.new

        mock(logger).on_failure(command, exception, [event])

        listener = AuditingUnitListener.new command, EmptyDataProvider.new, logger
        listener.recorded_events.push event

        listener.on_rollback Object.new, exception
      end
    end

  end
end
