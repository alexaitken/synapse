require 'test_helper'

module Synapse
  module Configuration
    class ExtensionTest < Test::Unit::TestCase
      def test_build
        Synapse.build do
          factory :test_service do
            'test_result'
          end
        end

        assert_equal 'test_result', Synapse.container[:test_service]
      end
    end
  end
end
