require 'spec_helper'

module Synapse
  module Configuration

    describe Extension do
      it 'delegates building to the service container' do
        reference = Object.new

        Synapse.build do
          factory :test_service do
            reference
          end
        end

        expect(Synapse.container.resolve(:test_service)).to be(reference)
      end
    end

  end
end
