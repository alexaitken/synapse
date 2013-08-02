require 'spec_helper'

module Synapse
  module Command

    describe MappingCommandHandler do
      it 'passes the command to the correct mapped handler' do
        handler = ExampleMappingCommandHandler.new
        unit = Object.new

        command = CommandMessage.build do |builder|
          builder.payload = TestCommand.new
        end

        handler.handle command, unit
        handler.handled.should be_true

        command = CommandMessage.build do |builder|
          builder.payload = TestSubCommand.new
        end

        handler.handle command, unit
        handler.sub_handled.should be_true

        command = CommandMessage.build do |builder|
          builder.payload = 5
        end

        expect {
          handler.handle command, unit
        }.to raise_error(ArgumentError)
      end

      it 'provides the command types it supports' do
        handler = ExampleMappingCommandHandler.new
        handler.supported_commands.should == [TestCommand, TestSubCommand]
      end
    end

    class TestCommand; end
    class TestSubCommand; end

    class ExampleMappingCommandHandler
      include MappingCommandHandler

      attr_accessor :handled, :sub_handled

      map_command TestCommand do |command, message, current_unit|
        raise ArgumentError unless TestCommand === command
        raise ArgumentError unless CommandMessage === message
        raise ArgumentError if current_unit.nil?

        @handled = true
      end

      map_command TestSubCommand, :to => :on_sub

      def on_sub(command)
        @sub_handled = true
      end
    end

  end
end
