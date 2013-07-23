require 'spec_helper'

module Synapse
  module Auditing

    describe CommandMetadataProvider do
      it 'provides the metadata from a command for auditing' do
        metadata = {
          foo: 0
        }

        provider = CommandMetadataProvider.new
        command = Command::CommandMessage.build do |builder|
          builder.metadata = metadata
        end

        provider.provide_data_for(command).should == metadata
      end
    end

    describe CorrelationDataProvider do
      it 'provides the identifier of a command for auditing' do
        provider = CorrelationDataProvider.new
        command = Command::CommandMessage.build

        expected = {
          command_id: command.id
        }
        provider.provide_data_for(command).should == expected
      end

      it 'provides the identifier of a command for auditing using an alternate key' do
        provider = CorrelationDataProvider.new :some_id
        command = Command::CommandMessage.build

        expected = {
          some_id: command.id
        }
        provider.provide_data_for(command).should == expected
      end
    end

  end
end
