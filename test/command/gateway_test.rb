require 'test_helper'

module Synapse
  module Command

    class CommandGatewayTest < Test::Unit::TestCase
      def test_send
        command_bus = Object.new
        gateway = CommandGateway.new command_bus

        command = Object.new
        command_message = CommandMessage.build do |builder|
          builder.payload = command
        end

        mock(command_bus).dispatch(is_a(CommandMessage)).ordered
        mock(command_bus).dispatch(command_message).ordered

        gateway.send command
        gateway.send command_message
      end
    end

  end
end
