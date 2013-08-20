require 'spec_helper'

module Synapse
  module Command

    describe CommandGateway do
      let(:command_bus) { Object.new }

      subject do
        CommandGateway.new command_bus
      end

      it 'filters commands before sending them to the command bus' do
        filter = Object.new
        subject.filters << filter

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
    end

  end
end
