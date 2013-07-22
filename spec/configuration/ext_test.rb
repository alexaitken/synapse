require 'test_helper'

module Synapse
  module Configuration
    describe Extension do
      should 'delegate building to the service container' do
        reference = Object.new

        Synapse.build do
          factory :test_service do
            reference
          end
        end

        assert_same reference, Synapse.container[:test_service]
      end
    end
  end
end
