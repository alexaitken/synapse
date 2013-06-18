require 'test_helper'

module Synapse
  module Auditing

    class CommandMetadataProviderTest < Test::Unit::TestCase
      should 'provide the metadata from a command for auditing' do
        data = { foo: 0 }

        provider = CommandMetadataProvider.new
        command = Command::CommandMessage.build do |builder|
          builder.metadata = data
        end

        assert_equal data, provider.provide_data_for(command)
      end
    end

    class CorrelationDataProviderTest < Test::Unit::TestCase
      should 'provide the identifier of a command for auditing' do
        provider = CorrelationDataProvider.new
        command = Command::CommandMessage.build

        expected = { :command_id => command.id }
        assert_equal expected, provider.provide_data_for(command)
      end

      should 'provide the identifier of a command for auditing using an alternate key' do
        provider = CorrelationDataProvider.new :correlation_id
        command = Command::CommandMessage.build

        expected = { :correlation_id => command.id }
        assert_equal expected, provider.provide_data_for(command)
      end
    end

  end
end
