require 'test_helper'
require 'configuration/fixtures/dependent'

module Synapse
  module Configuration
    class DependentTest < Test::Unit::TestCase

      should 'create accessors for injectable attributes' do
        dependent = ExampleDependent.new

        service_a = Object.new
        service_b = Object.new

        dependent.service_a = service_a
        dependent.some_service = service_b

        assert_same service_a, dependent.service_a
        assert_same service_b, dependent.some_service
      end

      should 'track which services to inject in which attributes' do
        dependencies = ExampleDependent.dependencies

        assert_equal :service_a, dependencies[:service_a]
        assert_equal :some_service, dependencies[:service_b]
      end

    end
  end
end
