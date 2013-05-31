require 'test_helper'

module Synapse
  module Command

    class CommandGatewayTest < Test::Unit::TestCase
      should 'wrap bare command objects in command messages before dispatch' do
        command_bus = Object.new
        gateway = CommandGateway.new command_bus

        command = Object.new
        command_message = CommandMessage.build do |builder|
          builder.payload = command
        end

        mock(command_bus).dispatch_with_callback(is_a(CommandMessage), anything).ordered
        mock(command_bus).dispatch_with_callback(command_message, anything).ordered

        gateway.send command
        gateway.send command_message
      end
    end

  end
end
