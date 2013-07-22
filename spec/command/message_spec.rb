require 'spec_helper'

module Synapse
  module Command

    describe CommandMessage do
      it 'does not wrap objects that are already command messages' do
        command = Object.new
        command_message = CommandMessage.build

        CommandMessage.as_message(command_message).should be(command_message)

        wrapped = CommandMessage.as_message(command)

        wrapped.should be_a(CommandMessage)
        wrapped.payload.should be(command)
      end
    end

  end
end
