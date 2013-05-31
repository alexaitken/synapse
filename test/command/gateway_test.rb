require 'test_helper'

module Synapse
  module Command

    class CommandGatewayTest < Test::Unit::TestCase
      def setup
        @command_bus = Object.new
        @gateway = CommandGateway.new @command_bus
      end

      should 'wrap bare command objects in command messages before dispatch' do
        command = Object.new
        command_message = CommandMessage.build do |builder|
          builder.payload = command
        end

        mock(@command_bus).dispatch_with_callback(is_a(CommandMessage), anything).ordered
        mock(@command_bus).dispatch_with_callback(command_message, anything).ordered

        @gateway.send command
        @gateway.send command_message
      end

      should 'wrap callback in RetryingCallback if RetryScheduler' do
        @gateway.retry_scheduler = IntervalRetryScheduler.new 3, 3

        command = Object.new
        callback = CommandCallback.new

        mock(@command_bus).dispatch_with_callback(is_a(CommandMessage), is_a(RetryingCallback))

        @gateway.send_with_callback command, callback
      end

      should 'send a command and wait for it to be dispatched' do
        @gateway.retry_scheduler = IntervalRetryScheduler.new 3, 3

        command = Object.new
        result = Object.new

        mock(@command_bus).dispatch_with_callback(is_a(CommandMessage), is_a(RetryingCallback)) do |message, callback|
          callback.on_success result
        end

        received_result = nil

        Thread.new do
          received_result = @gateway.send_and_wait(command)
        end

        wait_until do
          received_result.equal? result
        end
      end
    end

  end
end
