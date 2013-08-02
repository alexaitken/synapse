require 'spec_helper'

module Synapse
  module Command

    describe CommandGateway do
      CountdownLatch = Contender::CountdownLatch

      let :command_bus do
        Object.new
      end

      subject do
        CommandGateway.new command_bus
      end

      it 'filters commands before sending them to the command bus' do
        filter = Object.new
        subject.filters = [filter]

        command = CommandMessage.build
        replaced_command = CommandMessage.build

        mock(filter).filter(command) do
          replaced_command
        end

        mock(command_bus).dispatch_with_callback(replaced_command, is_a(VoidCallback))

        subject.send command
      end

      it 'wraps bare command objects in command messages before dispatch' do
        command = Object.new
        command_message = CommandMessage.build do |builder|
          builder.payload = command
        end

        mock(command_bus).dispatch_with_callback(is_a(CommandMessage), anything).ordered
        mock(command_bus).dispatch_with_callback(command_message, anything).ordered

        subject.send command
        subject.send command_message
      end

      it 'wraps callback in RetryingCallback if a retry scheduler is set' do
        subject.retry_scheduler = create_retry_scheduler

        command = Object.new
        callback = CommandCallback.new

        mock(command_bus).dispatch_with_callback(is_a(CommandMessage), is_a(RetryingCallback))

        subject.send_with_callback command, callback
      end

      it 'sends a command and waits for it to be dispatched' do
        subject.retry_scheduler = create_retry_scheduler

        command = Object.new
        result = Object.new

        mock(command_bus).dispatch_with_callback(is_a(CommandMessage), is_a(RetryingCallback)) do |message, callback|
          callback.on_success result
        end

        received_result = nil
        result_latch = CountdownLatch.new 1

        Thread.new do
          received_result = subject.send_and_wait command
          result_latch.countdown
        end

        result_latch.await
        received_result.should be(result)
      end

    private

      def create_retry_scheduler
        IntervalRetryScheduler.new 3, 3, Object.new # Mock schedule provider
      end
    end

  end
end
