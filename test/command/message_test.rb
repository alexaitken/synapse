require 'test_helper'

module Synapse
  module Command
    class CommandMessageTest < Test::Unit::TestCase
      def test_as_message
        command = Object.new
        command_message = CommandMessage.build

        assert_same command_message, CommandMessage.as_message(command_message)

        wrapped = CommandMessage.as_message(command)
        assert_same command, wrapped.payload
      end
    end
  end
end
