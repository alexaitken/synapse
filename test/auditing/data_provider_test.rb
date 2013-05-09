require 'test_helper'

module Synapse
  module Auditing

    class CommandMetadataProviderTest < Test::Unit::TestCase
      def test_provide_data_for
        data = { foo: 0 }

        provider = CommandMetadataProvider.new
        command = Command::CommandMessage.build do |builder|
          builder.metadata = data
        end

        assert_equal data, provider.provide_data_for(command)
      end
    end

    class CorrelationDataProviderTest < Test::Unit::TestCase
      def test_provide_data_for
        provider = CorrelationDataProvider.new
        command = Command::CommandMessage.build

        expected = { :command_id => command.id }
        assert_equal expected, provider.provide_data_for(command)
      end
    end

  end
end
