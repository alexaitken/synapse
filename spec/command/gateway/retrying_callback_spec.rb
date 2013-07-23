require 'spec_helper'

module Synapse
  module Command

    describe RetryingCallback do
      before do
        @command = CommandMessage.as_message Object.new
        @delegate = Object.new
        @retry_scheduler = Object.new
        @command_bus = Object.new

        @callback = RetryingCallback.new @delegate, @command, @retry_scheduler, @command_bus
      end

      it 'notifies delegate of a successful dispatch' do
        result = Object.new

        mock(@delegate).on_success(result)
        @callback.on_success result
      end

      it 'does not notify delegate of a failed dispatch when rescheduling' do
        failures = [RuntimeError.new]

        mock(@command_bus).dispatch_with_callback(@command, @callback)

        mock(@retry_scheduler).schedule(@command, failures, is_a(Proc)) do |_, _, dispatcher|
          dispatcher.call
          true
        end

        @callback.on_failure failures.last
      end

      it 'notifies delegate of a failed dispatch when not rescheduling' do
        failures = [RuntimeError.new]

        mock(@retry_scheduler).schedule(@command, failures, is_a(Proc)) do
          false
        end
        mock(@delegate).on_failure(failures.last)

        @callback.on_failure failures.last
      end

      it 'notifies delegate of a failed dispatch on an unchecked exception' do
        failure = ThreadError.new

        mock(@delegate).on_failure(failure)

        @callback.on_failure failure
      end
    end

  end
end
